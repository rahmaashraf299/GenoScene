"""
GenoScene Local ML Server
=========================
FastAPI server that runs the same ML models from Merged_models.ipynb.
Accepts CSV file uploads and returns real Eye/Hair/Skin predictions.

Usage:
    1. Place 'final_merged_3.csv' in this folder (or project root)
    2. pip install -r requirements.txt
    3. python server.py
"""

import os
import io
import numpy as np
import pandas as pd
from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from typing import Optional
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import HistGradientBoostingClassifier, RandomForestClassifier
from xgboost import XGBClassifier
import lightgbm as lgb

import warnings
warnings.filterwarnings('ignore')

# ─── Global model state ───
models = {}
app = FastAPI(title="GenoScene ML Server")

# CORS: allow Flutter app (web, mobile emulator, etc.)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# ═══════════════════════════════════════════════
# Model Training (runs once on startup)
# ═══════════════════════════════════════════════

def find_dataset():
    """Look for final_merged_3.csv in common locations."""
    candidates = [
        os.path.join(os.path.dirname(__file__), "final_merged_3.csv"),
        os.path.join(os.path.dirname(__file__), "..", "final_merged_3.csv"),
        "final_merged_3.csv",
    ]
    for path in candidates:
        if os.path.isfile(path):
            return path
    return None


def train_models():
    """Train Eye/Hair/Skin models exactly as in Merged_models.ipynb."""
    dataset_path = find_dataset()
    if dataset_path is None:
        raise FileNotFoundError(
            "Cannot find 'final_merged_3.csv'. "
            "Place it in the backend/ folder or project root."
        )

    print(f"Loading dataset from: {dataset_path}")
    df = pd.read_csv(dataset_path)
    print(f"Dataset shape: {df.shape}")

    # ── Targets ──
    EYE_TARGET = "Predicted_Eye_Color"
    HAIR_TARGET = "Predicted_Hair_Color"
    SKIN_TARGET = "Predicted_Skin_Color"

    # Merge VeryPale -> Pale (as in notebook)
    SKIN_TARGET_MERGED = "Predicted_Skin_Color_merged"
    df[SKIN_TARGET_MERGED] = df[SKIN_TARGET].replace("VeryPale", "Pale")

    # ── SNP columns ──
    snp_cols = [c for c in df.columns if c.startswith("rs")]
    features = snp_cols

    # ── Feature Selection using Random Forest (as in notebook) ──
    targets_fs = {
        "Eye Color": EYE_TARGET,
        "Hair Color": HAIR_TARGET,
        "Skin Color": SKIN_TARGET_MERGED,
    }
    target_n_features = {"Eye Color": 13, "Hair Color": 35, "Skin Color": 30}
    independent_high_impact_snps = {}

    for label, target_col in targets_fs.items():
        n = target_n_features[label]
        X_fs = df[features]
        y_fs = df[target_col].astype(str)
        rf = RandomForestClassifier(n_estimators=100, random_state=42)
        rf.fit(X_fs, y_fs)
        importances = pd.Series(rf.feature_importances_, index=features)
        top_n = importances.nlargest(n).index.tolist()
        independent_high_impact_snps[label] = top_n

    for trait, snps in independent_high_impact_snps.items():
        print(f"  {trait}: {len(snps)} SNPs selected")

    selected_snps_eye = independent_high_impact_snps["Eye Color"]
    selected_snps_hair = independent_high_impact_snps["Hair Color"]
    selected_snps_skin = independent_high_impact_snps["Skin Color"]

    # ── Per-trait feature matrices ──
    X_eye = df[selected_snps_eye].values
    X_hair = df[selected_snps_hair].values
    X_skin = df[selected_snps_skin].values

    # ── Train each trait with all 4 algorithms, pick the best ──

    def compute_metrics(y_true, y_pred, y_proba, n_classes):
        from sklearn.metrics import accuracy_score, f1_score, log_loss
        return {
            "Accuracy": round(accuracy_score(y_true, y_pred), 4),
            "Macro_F1": round(f1_score(y_true, y_pred, average="macro"), 4),
            "Log_Loss": round(log_loss(y_true, y_proba, labels=list(range(n_classes))), 4),
        }

    def train_eval_trait(trait_name, target_col, X_all):
        le = LabelEncoder()
        y_all = le.fit_transform(df[target_col].astype(str))
        classes = le.classes_
        n_classes = len(classes)

        X_train, X_test, y_train, y_test = train_test_split(
            X_all, y_all, test_size=0.2, random_state=42, stratify=y_all
        )

        # Logistic Regression
        logreg = Pipeline([
            ("scaler", StandardScaler()),
            ("clf", LogisticRegression(
                multi_class="multinomial", solver="lbfgs",
                max_iter=2000, class_weight="balanced"
            ))
        ])
        logreg.fit(X_train, y_train)
        y_pred_lr = logreg.predict(X_test)
        y_proba_lr = logreg.predict_proba(X_test)
        lr_metrics = compute_metrics(y_test, y_pred_lr, y_proba_lr, n_classes)

        # LightGBM
        objective = "binary" if n_classes == 2 else "multiclass"
        lgbm = lgb.LGBMClassifier(
            objective=objective,
            num_class=n_classes if objective == "multiclass" else None,
            n_estimators=400, learning_rate=0.05, num_leaves=31,
            subsample=0.9, colsample_bytree=0.9, random_state=42,
            class_weight="balanced" if objective == "multiclass" else None,
            n_jobs=-1, verbose=-1,
        )
        X_tr, X_val, y_tr, y_val = train_test_split(
            X_train, y_train, test_size=0.15, random_state=42, stratify=y_train
        )
        lgbm.fit(X_tr, y_tr, eval_set=[(X_val, y_val)],
                 callbacks=[lgb.early_stopping(stopping_rounds=25, verbose=False)])
        y_pred_lgb = lgbm.predict(X_test)
        y_proba_lgb = lgbm.predict_proba(X_test)
        lgb_metrics = compute_metrics(y_test, y_pred_lgb, y_proba_lgb, n_classes)

        # XGBoost
        xgb_model = XGBClassifier(
            objective="multi:softprob", num_class=n_classes,
            n_estimators=300, max_depth=4, learning_rate=0.05, random_state=42,
        )
        xgb_model.fit(X_train, y_train)
        y_pred_xgb = xgb_model.predict(X_test)
        y_proba_xgb = xgb_model.predict_proba(X_test)
        xgb_metrics = compute_metrics(y_test, y_pred_xgb, y_proba_xgb, n_classes)

        # HistGradientBoosting
        hist = HistGradientBoostingClassifier(
            max_iter=200, max_depth=5, learning_rate=0.05,
            random_state=42, class_weight="balanced",
        )
        hist.fit(X_train, y_train)
        y_pred_hist = hist.predict(X_test)
        y_proba_hist = hist.predict_proba(X_test)
        hist_metrics = compute_metrics(y_test, y_pred_hist, y_proba_hist, n_classes)

        print(f"  {trait_name}: LogReg={lr_metrics['Macro_F1']}, LGBM={lgb_metrics['Macro_F1']}, "
              f"XGB={xgb_metrics['Macro_F1']}, HistGB={hist_metrics['Macro_F1']}")

        return {
            "label_encoder": le, "classes": classes,
            "logreg_model": logreg, "lgbm_model": lgbm,
            "xgb_model": xgb_model, "hist_model": hist,
            "logreg_metrics": lr_metrics, "lgbm_metrics": lgb_metrics,
            "xgb_metrics": xgb_metrics, "hist_metrics": hist_metrics,
        }

    def choose_best_model(res_dict):
        candidates = [
            ("LogReg", res_dict["logreg_metrics"], res_dict["logreg_model"]),
            ("LGBM", res_dict["lgbm_metrics"], res_dict["lgbm_model"]),
            ("XGB", res_dict["xgb_metrics"], res_dict["xgb_model"]),
            ("HistGB", res_dict["hist_metrics"], res_dict["hist_model"]),
        ]
        best = sorted(candidates, key=lambda x: (-x[1]["Macro_F1"], x[1]["Log_Loss"]))[0]
        return best[0], best[2]

    print("Training models...")
    eye_res = train_eval_trait("Eye Color", EYE_TARGET, X_eye)
    hair_res = train_eval_trait("Hair Color", HAIR_TARGET, X_hair)
    skin_res = train_eval_trait("Skin Color", SKIN_TARGET_MERGED, X_skin)

    eye_choice, eye_final_model = choose_best_model(eye_res)
    hair_choice, hair_final_model = choose_best_model(hair_res)
    skin_choice, skin_final_model = choose_best_model(skin_res)

    print(f"\nFinal model choices: Eye={eye_choice}, Hair={hair_choice}, Skin={skin_choice}")

    # Store everything globally
    models["eye"] = {
        "model": eye_final_model,
        "label_encoder": eye_res["label_encoder"],
        "snps": selected_snps_eye,
    }
    models["hair"] = {
        "model": hair_final_model,
        "label_encoder": hair_res["label_encoder"],
        "snps": selected_snps_hair,
    }
    models["skin"] = {
        "model": skin_final_model,
        "label_encoder": skin_res["label_encoder"],
        "snps": selected_snps_skin,
    }
    # Union of all required SNPs for validation
    models["all_required_snps"] = sorted(
        set(selected_snps_eye) | set(selected_snps_hair) | set(selected_snps_skin)
    )

    print("Models trained successfully!")


# ═══════════════════════════════════════════════
# Inference helpers
# ═══════════════════════════════════════════════

def entropy(probs):
    return float(-np.sum(probs * np.log(probs + 1e-9)))


def predict_single(df_row):
    """Run inference for a single sample row."""
    result = {}

    for trait in ["eye", "hair", "skin"]:
        m = models[trait]
        snps = m["snps"]
        X_i = df_row[snps].values.reshape(1, -1)
        proba = m["model"].predict_proba(X_i)[0]
        classes = m["label_encoder"].classes_

        top_idx = int(np.argmax(proba))
        # Return probabilities as 0.0–1.0 fractions (Flutter expects this)
        prob_dict = {str(c): round(float(v), 4) for c, v in zip(classes, proba)}

        result[trait] = prob_dict

    # Overall confidence (mean of top probabilities)
    overall = np.mean([max(result[t].values()) for t in ["eye", "hair", "skin"]])
    result["overall_confidence"] = round(overall * 100, 2)

    return result


# ═══════════════════════════════════════════════
# API Endpoints
# ═══════════════════════════════════════════════

@app.post("/analyze")
async def analyze(file: UploadFile = File(...), sample_name: Optional[str] = Form(None)):
    """Accept a CSV file and return trait predictions."""
    if not models:
        raise HTTPException(status_code=503, detail="Models not loaded yet. Please wait.")

    # Read uploaded CSV
    content = await file.read()
    try:
        df_in = pd.read_csv(io.BytesIO(content))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid CSV file: {str(e)}")

    # Validate required SNP columns
    all_snps = models["all_required_snps"]
    missing = [c for c in all_snps if c not in df_in.columns]
    if missing:
        raise HTTPException(
            status_code=400,
            detail=f"Missing {len(missing)} required SNP columns: {missing[:10]}..."
                   if len(missing) > 10 else f"Missing required SNP columns: {missing}"
        )

    # Run inference for each row
    results = []
    for i in range(len(df_in)):
        row = df_in.iloc[i]
        pred = predict_single(row)
        results.append(pred)

    return {"success": True, "results": results}


@app.get("/health")
async def health():
    """Health check endpoint."""
    return {
        "status": "ok",
        "models_loaded": bool(models),
        "required_snps_count": len(models.get("all_required_snps", [])),
    }


# ═══════════════════════════════════════════════
# Startup
# ═══════════════════════════════════════════════

@app.on_event("startup")
async def startup():
    train_models()


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
