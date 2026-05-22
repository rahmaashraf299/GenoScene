from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
# from django.conf import settings
# from django.conf.urls.static import static

# استيراد كل الـ views اللي عندك
from .views import (
    RegisterView,
    CustomTokenObtainPairView,
    DNASampleViewSet,
    PredictionViewSet,
    UserProfileView,
    ChangePasswordView,
    LogoutView,
    ForgotPasswordView,
    ResetPasswordView,
    ContactUsView,
    analyze_dna,
    generate_face,
    analysis_history,
    model_logs,
    delete_analysis,           # ← إضافة حذف تحليل واحد
    clear_all_analyses,        # ← إضافة مسح كل التحاليل (Clear All)
)

router = DefaultRouter()
router.register(r'dna-samples', DNASampleViewSet, basename='dna-sample')
router.register(r'predictions', PredictionViewSet, basename='prediction')

urlpatterns = [
    # Auth
    path('register/', RegisterView.as_view(), name='register'),
    path('token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('logout/', LogoutView.as_view(), name='logout'),

    # User Profile & Settings
    path('me/', UserProfileView.as_view(), name='user-profile'),
    path('me/change-password/', ChangePasswordView.as_view(), name='change-password'),

    # Password Reset
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),
    path('reset-password/', ResetPasswordView.as_view(), name='reset-password'),

    # Contact & Misc
    path('contact-us/', ContactUsView.as_view(), name='contact-us'),

    # Core Endpoints (DNA & AI)
    path('', include(router.urls)),  # dna-samples + predictions
    path('analyze/', analyze_dna, name='analyze_dna'),
    path('generate-face/', generate_face, name='generate_face'),

    # History & Logs
    path('analysis-history/', analysis_history, name='analysis_history'),
    path('model-logs/', model_logs, name='model_logs'),

    # Delete Endpoints (الجديدة)
    path('analysis/<int:analysis_id>/delete/', delete_analysis, name='delete_analysis'),
    path('analyses/clear-all/', clear_all_analyses, name='clear_all_analyses'),
]

# if settings.DEBUG:
#     urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)