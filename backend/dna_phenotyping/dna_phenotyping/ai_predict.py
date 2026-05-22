# dna_phenotyping/ai_predict.py
import os
import pandas as pd
import numpy as np
import joblib
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import HistGradientBoostingClassifier

# مسار الداتا سيت (غيّري لو لازم)
DATA_PATH = os.path.join(os.path.dirname(__file__), '../ml/final_merged_3.csv')

# ── دالة التدريب (تشغل مرة واحدة) ──
def train_and_save_models():
    if not os.path.exists(DATA_PATH):
        raise FileNotFoundError(f"Dataset not found: {DATA_PATH}")

    print(f"Loading dataset from: {DATA_PATH}")
    df = pd.read_csv(DATA_PATH)

    # Targets (من server.py)
    EYE_TARGET = "Predicted_Eye_Color"
    HAIR_TARGET = "Predicted_Hair_Color"
    SKIN_TARGET = "Predicted_Skin_Color"

    # Merge VeryPale -> Pale
    df["Predicted_Skin_Color_merged"] = df[SKIN_TARGET].replace("VeryPale", "Pale")

    # SNP columns
    snp_cols = [c for c in df.columns if c.startswith("rs")]

    # بسيط جدًا: ندرب 3 موديلات (HistGradientBoosting كمثال)
    def train_trait(target_col):
        le = LabelEncoder()
        y = le.fit_transform(df[target_col])
        X = df[snp_cols]
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        model = HistGradientBoostingClassifier(max_iter=200, random_state=42)
        model.fit(X_train, y_train)
        return model, le

    eye_model, eye_le = train_trait(EYE_TARGET)
    hair_model, hair_le = train_trait(HAIR_TARGET)
    skin_model, skin_le = train_trait("Predicted_Skin_Color_merged")

    # حفظ الموديلات
    os.makedirs('models', exist_ok=True)
    joblib.dump(eye_model, 'models/eye_model.joblib')
    joblib.dump(hair_model, 'models/hair_model.joblib')
    joblib.dump(skin_model, 'models/skin_model.joblib')

    print("Models trained and saved!")

# ── دالة الـ predict (للـ endpoint) ──
def predict_from_csv(df):
    eye_model = joblib.load('models/eye_model.joblib')
    hair_model = joblib.load('models/hair_model.joblib')
    skin_model = joblib.load('models/skin_model.joblib')

    # خدي الـ columns اللي الموديل محتاجها (من feature_names_in_ لو موجود)
    snp_cols = eye_model.feature_names_in_ if hasattr(eye_model, 'feature_names_in_') else [c for c in df.columns if c.startswith("rs")]

    missing = [col for col in snp_cols if col not in df.columns]
    if missing:
        raise ValueError(f"Missing columns: {missing}")

    X = df[snp_cols]

    eye_pred = eye_model.predict_proba(X)[0]
    hair_pred = hair_model.predict_proba(X)[0]
    skin_pred = skin_model.predict_proba(X)[0]

    # أسماء الكلاسات الحقيقية من الداتا سيت
    eye_classes = ["Blue", "Brown", "Intermediate"]
    hair_classes = ["Blond", "Brown", "Black", "Red"]
    skin_classes = ["Light", "Dark", "Intermediate", "VeryPale", "Pale"]

    # أعلى احتمال لكل صفة (للـ summary)
    eye_idx = np.argmax(eye_pred)
    hair_idx = np.argmax(hair_pred)
    skin_idx = np.argmax(skin_pred)

    result = {
        "eye": {eye_classes[i]: float(eye_pred[i] * 100) for i in range(min(len(eye_classes), len(eye_pred)))},
        "hair": {hair_classes[i]: float(hair_pred[i] * 100) for i in range(min(len(hair_classes), len(hair_pred)))},
        "skin": {skin_classes[i]: float(skin_pred[i] * 100) for i in range(min(len(skin_classes), len(skin_pred)))},
        "summary": {
            "eye": eye_classes[eye_idx],
            "hair": hair_classes[hair_idx],
            "skin": skin_classes[skin_idx],
        },
        "overall_confidence": round(np.mean([eye_pred[eye_idx], hair_pred[hair_idx], skin_pred[skin_idx]]) * 100, 2)
    }

    return result