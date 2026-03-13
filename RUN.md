# تشغيل مشروع GenoScene (Flutter + Backend)

## 1) تشغيل تطبيق Flutter

المشروع يستخدم نقطة دخول في `lib/main.dart` (تستدعي `lib/screens/main.dart`).

### المتطلبات
- Flutter SDK مثبت (`flutter --version`)
- Chrome أو Windows كـ device

### الأوامر
```bash
cd "d:\مشروع التخرج\.test\dna\dna"
flutter pub get
flutter run -d chrome
```
أو للتشغيل على **Windows**:
```bash
flutter run -d windows
```

### إذا ظهر خطأ في google_fonts
تم ضبط `google_fonts: ^6.3.2` في `pubspec.yaml` لتجنب خطأ Constant evaluation مع Dart 3. إذا استمر الخطأ:
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

---

## 2) الـ Backend (Django)

حالياً **لا يوجد مشروع Django داخل مجلد dna**. التطبيق يتوقع:

| الوظيفة        | الرابط المتوقع              | الملف في Flutter        |
|----------------|-----------------------------|---------------------------|
| تسجيل الدخول   | Ngrok (مُعد في الكود)       | `auth_screen.dart`        |
| الملف الشخصي   | `http://127.0.0.1:8000/api/me/` | `edit_profile_screen.dart` |
| اتصل بنا       | `http://127.0.0.1:8000/api/contact-us/` | `contact_us_screen.dart`   |

- **Auth**: يستخدم حالياً رابط ngrok ثابت في `auth_screen.dart` (تسجيل دخول يعمل إذا كان السيرفر شغال).
- **Profile + Contact**: تحتاج سيرفر Django يعمل على `127.0.0.1:8000` مع endpoints أعلاه.

إذا كان عندك مشروع Django في مكان آخر، شغّله ثم شغّل Flutter. إذا تحتاج إنشاء مشروع Django من الصفر لهذه الـ API، يمكن إضافته لاحقاً.
