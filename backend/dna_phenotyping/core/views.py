from rest_framework import viewsets, status, generics
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.decorators import api_view, action, permission_classes
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.views import APIView
import requests
import csv
import io
from django.contrib.auth import update_session_auth_hash
from .serializers import ForgotPasswordSerializer, ResetPasswordSerializer
from django.core.mail import send_mail
from django.utils.crypto import get_random_string
from django.core.cache import cache
from django.core.files.base import ContentFile
from django.utils import timezone
import uuid
import urllib.parse
import random
from .models import DNASample, Prediction, User, Analysis, GeneratedFace, ModelLog
from rest_framework import serializers
from .serializers import (
    UserSerializer,
    RegisterSerializer,
    DNASampleSerializer,
    PredictionSerializer,
    UserProfileSerializer,
    PasswordChangeSerializer,
    ContactUsSerializer,
    PredictionCreateSerializer,
)


# ??????????????????????????????????????????????????????????
# Auth Views
# ??????????????????????????????????????????????????????????

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return Response({
            'user': UserSerializer(user).data,
            'tokens': {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            },
            'message': 'User registered successfully'
        }, status=status.HTTP_201_CREATED)


class CustomTokenObtainPairView(TokenObtainPairView):
    pass


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        return Response(
            {"detail": "Logged out successfully. Please clear tokens on client side."},
            status=status.HTTP_200_OK
        )


# ??????????????????????????????????????????????????????????
# Password Views
# ??????????????????????????????????????????????????????????

class ChangePasswordView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = PasswordChangeSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = request.user
        user.set_password(serializer.validated_data['new_password'])
        user.save()
        update_session_auth_hash(request, user)
        return Response({"detail": "Password updated successfully"}, status=status.HTTP_200_OK)


class ForgotPasswordView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']
        if not User.objects.filter(email=email).exists():
            return Response({"detail": "No user with this email exists."}, status=status.HTTP_400_BAD_REQUEST)
        code = get_random_string(length=6, allowed_chars='0123456789')
        cache.set(code, email, timeout=600)
        send_mail(
            subject='Password Reset Code',
            message=f'Your password reset code is: {code}\nValid for 10 minutes.',
            from_email="Genoscene <support@sabdalgelel.com>",
            recipient_list=[email],
            fail_silently=False,
        )
        return Response({"detail": "Reset code sent to your email"}, status=status.HTTP_200_OK)


class ResetPasswordView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        code = serializer.validated_data['code']
        email = cache.get(code)
        if not email:
            return Response({"detail": "Invalid or expired code"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({"detail": "User not found"}, status=status.HTTP_400_BAD_REQUEST)
        user.set_password(serializer.validated_data['new_password'])
        user.save()
        cache.delete(code)
        return Response({"detail": "Password reset successfully"}, status=status.HTTP_200_OK)


# ??????????????????????????????????????????????????????????
# Profile & Contact
# ??????????????????????????????????????????????????????????

class UserProfileView(generics.RetrieveUpdateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileSerializer

    def get_object(self):
        return self.request.user

    def perform_update(self, serializer):
        serializer.save()


class ContactUsView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ContactUsSerializer(data=request.data)
        if serializer.is_valid():
            send_mail(
                subject=f"Contact Us: {serializer.validated_data['subject']}",
                message=f"From: {serializer.validated_data['username']} ({serializer.validated_data['email']})\n\n{serializer.validated_data['body']}",
                from_email='your-sender-email@gmail.com',
                recipient_list=['sabdalgelel@gmail.com'],
                fail_silently=False,
            )
            return Response({"detail": "Message sent successfully"}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ??????????????????????????????????????????????????????????
# DNA Sample ViewSet
# ??????????????????????????????????????????????????????????

class DNASampleViewSet(viewsets.ModelViewSet):
    queryset = DNASample.objects.all()
    serializer_class = DNASampleSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(
        detail=False,
        methods=['POST'],
        parser_classes=[MultiPartParser, FormParser],
        url_path='upload-file'
    )
    def upload_file(self, request):
        file_obj = request.FILES.get('file')
        if not file_obj:
            return Response({"error": "No file provided"}, status=status.HTTP_400_BAD_REQUEST)
        if not file_obj.name.lower().endswith('.csv'):
            return Response({"error": "Only CSV files allowed"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            file_content = file_obj.read().decode('utf-8')
            rows = list(csv.reader(io.StringIO(file_content)))
            if len(rows) < 2:
                return Response({"error": "File must contain header and at least one data row"}, status=status.HTTP_400_BAD_REQUEST)
            header, data_row = rows[0], rows[1]
            if len(header) != len(data_row):
                return Response({"error": "Header and data row length mismatch"}, status=status.HTTP_400_BAD_REQUEST)
            snps_data = {}
            for snp_name, value in zip(header[1:], data_row[1:]):
                try:
                    snps_data[snp_name.strip()] = int(value.strip())
                except ValueError:
                    return Response({"error": f"Invalid value '{value}' for SNP {snp_name}"}, status=status.HTTP_400_BAD_REQUEST)
            sequence_data = {
                "sample_id": data_row[0],
                "sample_name": request.data.get('sample_name', f"Sample_{timezone.now().strftime('%Y-%m-%d_%H%M')}"),
                "snps": snps_data,
                "total_snps": len(snps_data),
                "filename": file_obj.name,
                "upload_method": "csv_file",
                "row_count": len(rows)
            }
            sample = DNASample.objects.create(user=request.user, sequence_data=sequence_data)
            return Response({
                "message": "File processed successfully",
                "sample_id": sample.id,
                "sample_name": sequence_data["sample_name"],
                "total_snps": len(snps_data),
                "preview": {k: v for k, v in list(snps_data.items())[:10]}
            }, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({"error": f"Error processing file: {str(e)}"}, status=status.HTTP_400_BAD_REQUEST)


# ??????????????????????????????????????????????????????????
# Prediction ViewSet
# ??????????????????????????????????????????????????????????

class PredictionViewSet(viewsets.ModelViewSet):
    serializer_class = PredictionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Prediction.objects.filter(analysis__user=self.request.user)

    def get_serializer_class(self):
        if self.action == 'create':
            return PredictionCreateSerializer
        return PredictionSerializer

    def perform_create(self, serializer):
        serializer.save()


# ??????????????????????????????????????????????????????????
# Analyze DNA ? FIX: scores now saved correctly
# ??????????????????????????????????????????????????????????

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def analyze_dna(request):
    print("===== START analyze_dna =====")
    print(f"User: {request.user.id}")
    print("Request data keys:", list(request.data.keys()))

    log = ModelLog.objects.create(
        dna_sample=None,
        status="processing",
        extra_data={
            "user_id": request.user.id,
            "request_time": str(timezone.now()),
            "type": "dna_analysis"
        }
    )

    # ?? 1. Validate file ??????????????????????????????????
    if 'file' not in request.FILES:
        log.status = "validation_error"
        log.error_message = "No CSV file uploaded"
        log.save()
        return Response({"error": "No CSV file uploaded"}, status=status.HTTP_400_BAD_REQUEST)

    file = request.FILES['file']
    sample_name = request.data.get(
        'sample_name',
        file.name or f"Sample_{timezone.now().strftime('%Y%m%d_%H%M')}"
    )
    file_bytes = file.read()

    # ?? 2. Send to ML Server ??????????????????????????????
    try:
        print("Sending file to ML Server v3 on port 8080...")
        ml_response = requests.post(
            "http://127.0.0.1:8080/analyze",
            files={"file": (file.name, io.BytesIO(file_bytes), "text/csv")},
            timeout=90
        )

        if ml_response.status_code != 200:
            raise Exception(f"ML Server returned status {ml_response.status_code}: {ml_response.text}")

        ml_data = ml_response.json()

        if not ml_data.get("success") or not ml_data.get("results"):
            raise Exception("Invalid response from ML Server")

        raw = ml_data["results"][0]

        def _flatten(trait_data: dict) -> dict:
            """Extract probabilities as pct dict ? supports both old and new ML Server format."""
            return trait_data.get("probabilities_pct", trait_data.get("probabilities", {}))

        result = {
            "eye":                _flatten(raw.get("eye",  {})),
            "hair":               _flatten(raw.get("hair", {})),
            "skin":               _flatten(raw.get("skin", {})),
            "summary":            raw.get("summary", {}),
            "overall_confidence": raw.get("overall_confidence", 0),
        }

    except Exception as e:
        print(f"ML Server error: {str(e)}")
        log.status = "failed"
        log.error_message = f"ML Server communication failed: {str(e)}"
        log.save()
        return Response({"error": "AI prediction service is not responding"}, status=status.HTTP_503_SERVICE_UNAVAILABLE)

    # ?? 3. Save DNASample ?????????????????????????????????
    try:
        dna_sample = DNASample.objects.create(
            user=request.user,
            sequence_data={
                "sample_name": sample_name,
                "filename": file.name,
                "upload_method": "direct_analyze",
                "raw_csv": file_bytes.decode("utf-8"),
            }
        )
        print(f"Created new DNASample ID: {dna_sample.id}")
    except Exception as e:
        print(f"Error saving DNASample: {str(e)}")
        dna_sample = None

    # ?? 4. Save Analysis & Prediction ????????????????????
    # FIX: this block is now OUTSIDE the DNASample except
    try:
        eye_data  = result.get("eye",  {})
        hair_data = result.get("hair", {})
        skin_data = result.get("skin", {})
        summary   = result.get("summary", {})

        # FIX: extract scores as max value from probability dict
        eye_score  = round(max(eye_data.values()),  2) if eye_data  else None
        hair_score = round(max(hair_data.values()), 2) if hair_data else None
        skin_score = round(max(skin_data.values()), 2) if skin_data else None

        # FIX: extract top label as key with max value
        eye_color  = max(eye_data,  key=eye_data.get)  if eye_data  else summary.get("eye")
        hair_color = max(hair_data, key=hair_data.get) if hair_data else summary.get("hair")
        skin_tone  = max(skin_data, key=skin_data.get) if skin_data else summary.get("skin")

        analysis = Analysis.objects.create(
            user=request.user,
            dna_sample=dna_sample,
            eye_results=eye_data,
            hair_results=hair_data,
            skin_results=skin_data,
            overall_confidence=result.get("overall_confidence", 0),
        )

        Prediction.objects.create(
            analysis=analysis,
            eye_color=eye_color,
            hair_color=hair_color,
            skin_tone=skin_tone,
            gender=summary.get("gender"),
            eye_score=eye_score,
            hair_score=hair_score,
            skin_score=skin_score,
        )

        log.dna_sample = dna_sample
        log.status = "success"
        log.extra_data.update({
            "service_used": "ml_server_v3",
            "analysis_id": analysis.id,
            "overall_confidence": result.get("overall_confidence"),
        })
        log.save()

        return Response({
            "success": True,
            "analysis_id": analysis.id,
            "dna_sample_id": dna_sample.id if dna_sample else None,
            "results": [result],
            "message": "Prediction completed using ML Server v3"
        })

    except Exception as e:
        print(f"Error saving analysis: {str(e)}")
        log.status = "failed"
        log.error_message = str(e)
        log.save()
        return Response({"error": "Failed to save analysis results"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ??????????????????????????????????????????????????????????
# Generate Face
# ??????????????????????????????????????????????????????????

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_face(request):
    print("===== START generate_face =====")
    print(f"User: {request.user.id}")

    log = ModelLog.objects.create(
        dna_sample=None,
        status="processing",
        extra_data={
            "user_id": request.user.id,
            "request_time": str(timezone.now()),
            "type": "face_generation"
        }
    )

    data = request.data
    hair_color  = data.get('hair_color')
    eye_color   = data.get('eye_color')
    skin_tone   = data.get('skin_tone')
    analysis_id = data.get('analysis_id')

    if not all([hair_color, eye_color, skin_tone, analysis_id]):
        log.status = "validation_error"
        log.error_message = "Missing required fields"
        log.save()
        return Response({"error": "Missing required fields"}, status=status.HTTP_400_BAD_REQUEST)

    airforce_prompt = (
        f"Realistic portrait of a person with {hair_color} hair, "
        f"{eye_color} eyes, and {skin_tone} skin. "
        "Front view, neutral background, detailed face."
    )

    pollinations_prompt = (
        f"Ultra realistic photorealistic close-up portrait of a young person, "
        f"could be male or female, {skin_tone.lower()} skin tone, "
        f"smooth flawless skin, clear complexion, no freckles, no blemishes, no acne, no scars, "
        f"{hair_color.lower()} hair, {eye_color.lower()} eyes, "
        "natural symmetrical face, realistic skin pores, soft natural lighting, "
        "neutral light gray background, professional studio photography, "
        "sharp details, 8k resolution, photorealistic, extremely lifelike, "
        "clean face, no imperfections, diverse gender appearance"
    )

    image_url    = None
    service_used = None

    # ?? 1. Try Airforce ???????????????????????????????????
    try:
        print("Trying Airforce...")
        response = requests.post(
            "https://api.airforce/v1/images/generations",
            json={"prompt": airforce_prompt, "model": "flux-2-dev", "n": 1, "size": "512x512"},
            timeout=45
        )
        print(f"Airforce status code: {response.status_code}")
        if response.status_code == 200:
            json_data = response.json()
            if json_data.get("data") and len(json_data["data"]) > 0:
                remote_url = json_data["data"][0].get("url")
                if remote_url:
                    image_url    = remote_url
                    service_used = "airforce"
                    print(f"Airforce succeeded ? {image_url}")
    except Exception as e:
        print(f"Airforce failed: {str(e)}")

    # ?? 2. Fallback: Pollinations ?????????????????????????
    if not image_url:
        try:
            print("Falling back to Pollinations...")
            encoded_prompt = urllib.parse.quote(pollinations_prompt)
            image_url    = f"https://image.pollinations.ai/prompt/{encoded_prompt}?width=512&height=512&seed={random.randint(1,999999)}&nologo=true"
            service_used = "pollinations"
            print(f"Pollinations URL: {image_url}")
        except Exception as e:
            log.status = "failed"
            log.error_message = f"Both Airforce and Pollinations failed: {str(e)}"
            log.save()
            return Response({"error": "Face generation services are currently unavailable"}, status=status.HTTP_503_SERVICE_UNAVAILABLE)

    # ?? 3. Download & Save ????????????????????????????????
    try:
        img_response = requests.get(image_url, timeout=60)
        if img_response.status_code != 200:
            raise Exception(f"Download failed: {img_response.status_code}")

        analysis = Analysis.objects.get(id=analysis_id, user=request.user)

        # FIX: use analysis.prediction (OneToOne) safely
        try:
            prediction = analysis.prediction
        except Prediction.DoesNotExist:
            raise Exception("Prediction not found for this analysis")

        generated_face = GeneratedFace.objects.create(
            prediction=prediction,
            prompt=pollinations_prompt if service_used == "pollinations" else airforce_prompt,
            image_url=image_url,
        )

        filename = f"face_{analysis_id}_{uuid.uuid4().hex[:12]}.jpg"
        generated_face.image.save(filename, ContentFile(img_response.content), save=True)

        log.dna_sample  = analysis.dna_sample
        log.status      = "success"
        log.extra_data.update({
            "final_image_url": generated_face.image.url,
            "remote_url":      image_url,
            "service_used":    service_used,
            "prediction_id":   prediction.id
        })
        log.save()

        full_image_url = request.build_absolute_uri(generated_face.image.url)

        print(f"? Face generated successfully using {service_used}")
        return Response({
            "success":       True,
            "image_url":     full_image_url,
            "prompt":        pollinations_prompt if service_used == "pollinations" else airforce_prompt,
            "analysis_id":   analysis_id,
            "prediction_id": prediction.id,
            "service_used":  service_used
        })

    except Analysis.DoesNotExist:
        log.status = "failed"
        log.error_message = f"Analysis {analysis_id} not found for this user"
        log.save()
        return Response({"error": "Analysis not found"}, status=status.HTTP_404_NOT_FOUND)

    except Exception as e:
        print(f"Error downloading/saving image: {str(e)}")
        log.status = "failed"
        log.error_message = str(e)
        log.save()
        return Response({"error": f"Failed to save generated image: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ??????????????????????????????????????????????????????????
# History & Logs
# ??????????????????????????????????????????????????????????

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def analysis_history(request):
    analyses = Analysis.objects.filter(
        user=request.user,
        is_deleted=False
    ).order_by('-created_at')

    data = []
    for analysis in analyses:
        # FIX: get face via prediction (OneToOne ? FK)
        face = None
        try:
            prediction = analysis.prediction
            face = prediction.generated_faces.filter(is_deleted=False).first()
        except Prediction.DoesNotExist:
            pass

        sample_name = "Unknown Sample"
        if analysis.dna_sample:
            seq = analysis.dna_sample.sequence_data
            sample_name = seq.get("sample_name") or seq.get("filename") or f"Sample #{analysis.id}"

        data.append({
            "id":                 analysis.id,
            "created_at":         analysis.created_at.isoformat(),
            "eye_results":        analysis.eye_results,
            "hair_results":       analysis.hair_results,
            "skin_results":       analysis.skin_results,
            "overall_confidence": analysis.overall_confidence,
            "face_image_url":     face.image_url if face else None,
            "sample_name":        sample_name,
        })

    return Response({"results": data})


class ModelLogSerializer(serializers.ModelSerializer):
    class Meta:
        model  = ModelLog
        fields = ['id', 'status', 'error_message', 'created_at', 'extra_data']
        read_only_fields = fields


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def model_logs(request):
    logs = ModelLog.objects.filter(
        dna_sample__user=request.user
    ).order_by('-created_at')[:20]
    return Response({
        "success": True,
        "logs":    ModelLogSerializer(logs, many=True).data
    })


# ??????????????????????????????????????????????????????????
# Delete Actions
# ??????????????????????????????????????????????????????????

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_analysis(request, analysis_id):
    try:
        analysis = Analysis.objects.get(id=analysis_id, user=request.user, is_deleted=False)
        analysis.soft_delete()

        # FIX: soft delete faces via prediction
        try:
            prediction = analysis.prediction
            prediction.generated_faces.update(is_deleted=True, deleted_at=timezone.now())
        except Prediction.DoesNotExist:
            pass

        return Response({"success": True, "message": "Analysis has been moved to trash"}, status=status.HTTP_200_OK)
    except Analysis.DoesNotExist:
        return Response({"error": "Analysis not found"}, status=status.HTTP_404_NOT_FOUND)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def clear_all_analyses(request):
    Analysis.objects.filter(user=request.user, is_deleted=False).update(
        is_deleted=True,
        deleted_at=timezone.now()
    )
    return Response({"success": True, "message": "All your analyses have been moved to trash"}, status=status.HTTP_200_OK)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_account(request):
    user = request.user
    Analysis.objects.filter(user=user).update(is_deleted=True, deleted_at=timezone.now())
    DNASample.objects.filter(user=user).update(is_deleted=True, deleted_at=timezone.now())
    user.is_active = False
    user.save()
    return Response({
        "success": True,
        "message": "Your account and all associated data have been deleted successfully."
    }, status=status.HTTP_200_OK)