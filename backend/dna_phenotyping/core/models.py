from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone


# Soft Delete Mixin (موصى به)
class SoftDeleteModel(models.Model):
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        abstract = True

    def soft_delete(self):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.save()

    def restore(self):
        self.is_deleted = False
        self.deleted_at = None
        self.save()

    def hard_delete(self):
        super().delete()


class User(AbstractUser):
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


class DNASample(SoftDeleteModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='dna_samples')
    sequence_data = models.JSONField(default=dict)
    uploaded_at = models.DateTimeField(auto_now_add=True)


class Analysis(SoftDeleteModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='analyses')
    dna_sample = models.OneToOneField(
        DNASample,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='analysis'
    )
    eye_results = models.JSONField()
    hair_results = models.JSONField()
    skin_results = models.JSONField()
    overall_confidence = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)



class Prediction(models.Model):
    analysis = models.OneToOneField(
        Analysis,
        on_delete=models.CASCADE,
        related_name='prediction'
    )
    eye_color = models.CharField(max_length=50, null=True, blank=True)
    hair_color = models.CharField(max_length=50, null=True, blank=True)
    skin_tone = models.CharField(max_length=50, null=True, blank=True)
    gender = models.CharField(max_length=20, null=True, blank=True)

    eye_score = models.FloatField(null=True, blank=True)
    hair_score = models.FloatField(null=True, blank=True)
    skin_score = models.FloatField(null=True, blank=True)
    # gender_score تم حذفه

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'prediction'

    def __str__(self):
        return f"Prediction for Analysis {self.analysis.id}"


class GeneratedFace(SoftDeleteModel):
    prediction = models.ForeignKey(
        Prediction,
        on_delete=models.CASCADE,
        related_name='generated_faces',
       
    )
    
    # # حقل مؤقت للتوافق مع البيانات القديمة
    # analysis = models.ForeignKey(
    #     Analysis,
    #     on_delete=models.SET_NULL,
    #     null=True,
    #     blank=True,
    #     related_name='generated_faces_old'
    # )

    image_url = models.URLField(max_length=1000, null=True, blank=True)
    image = models.ImageField(upload_to='generated_faces/', null=True, blank=True)
    prompt = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'generated_face'


class ModelLog(models.Model):
    dna_sample = models.ForeignKey(
        DNASample,
        on_delete=models.SET_NULL,
        related_name='model_logs',
        null=True,
        blank=True
    )
    status = models.CharField(max_length=30)
    error_message = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    extra_data = models.JSONField(null=True, blank=True, default=dict)

    class Meta:
        db_table = 'model_logs'
        indexes = [
            models.Index(fields=['dna_sample']),
            models.Index(fields=['status']),
            models.Index(fields=['-created_at']),
        ]