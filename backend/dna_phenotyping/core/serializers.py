from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import DNASample, Prediction, ModelLog
from django.core.mail import send_mail
from django.utils.crypto import get_random_string

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'created_at', 'profile_picture')
        read_only_fields = ('id', 'created_at')


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True)
    password2 = serializers.CharField(write_only=True, required=True, label="Confirm Password")

    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'password2')

    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Passwords don't match."})
        return attrs

    def create(self, validated_data):
        validated_data.pop('password2')
        user = User.objects.create_user(**validated_data)
        return user


class DNASampleSerializer(serializers.ModelSerializer):
    class Meta:
        model = DNASample
        fields = ('id', 'sequence_data', 'uploaded_at')
        read_only_fields = ('id', 'uploaded_at')


# class PredictionSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Prediction
#         fields = (
#             'id',
#             'eye_color', 'eye_score',
#             'hair_color', 'hair_score',
#             'skin_tone', 'skin_score',
#             'gender', 'gender_score',
#             'created_at'
#         )
#         read_only_fields = ('id', 'created_at')

class PredictionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Prediction
        fields = (
            'id',
            'eye_color', 'eye_score',
            'hair_color', 'hair_score',
            'skin_tone', 'skin_score',
            'gender', 'gender_score',
            'created_at'
        )
        read_only_fields = ('id', 'created_at')

class PredictionCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Prediction
        fields = (
            'dna_sample',
            'eye_color', 'eye_score',
            'hair_color', 'hair_score',
            'skin_tone', 'skin_score',
            'gender', 'gender_score',
        )




class ModelLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = ModelLog
        fields = '__all__'
        read_only_fields = ('created_at',)

class UserProfileSerializer(serializers.ModelSerializer):
    profile_picture = serializers.ImageField(
        allow_null=True,          # ← مهم
        required=False,           # ← مهم
        read_only=False,
        use_url=True
    )

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'profile_picture', 'created_at']
        read_only_fields = ['id', 'created_at']


class PasswordChangeSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True, write_only=True)
    new_password = serializers.CharField(required=True, write_only=True)
    new_password_confirm = serializers.CharField(required=True, write_only=True)

    def validate(self, attrs):
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError({"new_password": "The two passwords don't match."})
        return attrs

    def validate_old_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError("Old password is incorrect.")
        return value
    
    
class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)

    def validate_email(self, value):
        if not User.objects.filter(email=value).exists():
            raise serializers.ValidationError("No user with this email exists.")
        return value


class ResetPasswordSerializer(serializers.Serializer):
    code = serializers.CharField(required=True, max_length=6)
    new_password = serializers.CharField(required=True, write_only=True)
    new_password_confirm = serializers.CharField(required=True, write_only=True)

    def validate(self, attrs):
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError({"new_password": "Passwords do not match."})
        return attrs
    
    
class ContactUsSerializer(serializers.Serializer):
    username = serializers.CharField(required=True, max_length=100)
    email = serializers.EmailField(required=True)
    subject = serializers.CharField(required=True, max_length=200)
    body = serializers.CharField(required=True, max_length=2000)