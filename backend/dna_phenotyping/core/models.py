from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    """
    Custom User model
    """
    created_at = models.DateTimeField(auto_now_add=True)
    profile_picture = models.ImageField(
        upload_to='profile_pics/',
        null=True,
        blank=True,
    )

    class Meta:
        db_table = 'user'
        verbose_name = 'user'
        verbose_name_plural = 'users'

    groups = models.ManyToManyField(
        'auth.Group',
        related_name='custom_user_set',
        blank=True,
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        related_name='custom_user_set',
        blank=True,
    )


class DNASample(models.Model):
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='dna_samples'
    )
    sequence_data = models.JSONField(
        default=dict,
        help_text="Raw or processed DNA sequence data (JSON format)"
    )
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'dna_sample'
        verbose_name = 'DNA Sample'
        verbose_name_plural = 'DNA Samples'
        indexes = [
            models.Index(fields=['user'], name='idx_dnasample_user'),
            models.Index(fields=['uploaded_at'], name='idx_dnasample_uploaded_at'),
        ]


class Prediction(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='predictions')
    dna_sample = models.ForeignKey(
        DNASample,
        on_delete=models.SET_NULL,  # أفضل من CASCADE عشان ما يمسحش الـ prediction لو العينة اتشالت
        related_name='predictions',
        null=True,
        blank=True
    )
    eye_color = models.CharField(max_length=50, null=True, blank=True)
    hair_color = models.CharField(max_length=50, null=True, blank=True)
    skin_tone = models.CharField(max_length=50, null=True, blank=True)
    gender = models.CharField(max_length=20, null=True, blank=True)

    eye_score = models.FloatField(null=True, blank=True)
    hair_score = models.FloatField(null=True, blank=True)
    skin_score = models.FloatField(null=True, blank=True)
    gender_score = models.FloatField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'prediction'
        verbose_name = 'Prediction'
        verbose_name_plural = 'Predictions'
        indexes = [
            models.Index(fields=['user'], name='idx_prediction_user'),
            models.Index(fields=['dna_sample'], name='idx_prediction_dna_sample'),
            models.Index(fields=['-created_at'], name='idx_prediction_created_at_desc'),
        ]


class Analysis(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    dna_sample = models.ForeignKey(
        DNASample,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    eye_results = models.JSONField()
    hair_results = models.JSONField()
    skin_results = models.JSONField()
    overall_confidence = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Analysis {self.id} by {self.user.username}"


class GeneratedFace(models.Model):
    analysis = models.ForeignKey(Analysis, on_delete=models.CASCADE, related_name='faces')
    image_url = models.URLField()
    prompt = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Face for Analysis {self.analysis.id}"


class ModelLog(models.Model):
    dna_sample = models.ForeignKey(
        DNASample,
        on_delete=models.SET_NULL,
        related_name='model_logs',
        null=True,
        blank=True
    )
    status = models.CharField(
        max_length=30,
        help_text="processing, success, failed, timeout, validation_error, etc."
    )
    error_message = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    extra_data = models.JSONField(
        null=True,
        blank=True,
        default=dict,
        help_text="Additional metadata, model version, execution time, etc."
    )

    class Meta:
        db_table = 'model_logs'
        verbose_name = 'Model Log'
        verbose_name_plural = 'Model Logs'
        indexes = [
            models.Index(fields=['dna_sample'], name='idx_modellog_dna_sample'),
            models.Index(fields=['status'], name='idx_modellog_status'),
            models.Index(fields=['-created_at'], name='idx_modellog_created_at_desc'),
        ]