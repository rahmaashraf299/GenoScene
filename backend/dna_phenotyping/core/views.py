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
import pandas as pd
from django.utils import timezone
from dna_phenotyping.ai_predict import predict_from_csv
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
    PredictionSerializer, 
    PredictionCreateSerializer,
)


class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        refresh = RefreshToken.for_user(user)
        tokens = {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        }

        return Response({
            'user': UserSerializer(user).data,
            'tokens': tokens,
            'message': 'User registered successfully'
        }, status=status.HTTP_201_CREATED)


class CustomTokenObtainPairView(TokenObtainPairView):
    pass


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

        if not file_obj.name.lower().endswith(('.csv')):
            return Response({"error": "Only CSV files allowed"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            file_content = file_obj.read().decode('utf-8')
            csv_reader = csv.reader(io.StringIO(file_content))

            rows = list(csv_reader)
            if len(rows) < 2:
                return Response({"error": "File must contain header and at least one data row"}, status=status.HTTP_400_BAD_REQUEST)

            header = rows[0]
            data_row = rows[1]

            if len(header) != len(data_row):
                return Response({"error": "Header and data row length mismatch"}, status=status.HTTP_400_BAD_REQUEST)

            sample_id = data_row[0]
            snps_data = {}

            for snp_name, value in zip(header[1:], data_row[1:]):
                try:
                    snps_data[snp_name.strip()] = int(value.strip())
                except ValueError:
                    return Response(
                        {"error": f"Invalid value '{value}' for SNP {snp_name}"},
                        status=status.HTTP_400_BAD_REQUEST
                    )

            sequence_data = {
                "sample_id": sample_id,
                "sample_name": request.data.get('sample_name', f"Sample_{timezone.now().strftime('%Y-%m-%d_%H%M')}"),
                "snps": snps_data,
                "total_snps": len(snps_data),
                "filename": file_obj.name,
                "upload_method": "csv_file",
                "row_count": len(rows)
            }

            sample = DNASample.objects.create(
                user=request.user,
                sequence_data=sequence_data
            )

            return Response({
                "message": "File processed successfully",
                "sample_id": sample.id,
                "sample_name": sequence_data["sample_name"],
                "total_snps": len(snps_data),
                "preview": {k: v for k, v in list(snps_data.items())[:10]}  
            }, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response(
                {"error": f"Error processing file: {str(e)}"},
                status=status.HTTP_400_BAD_REQUEST
            )


class PredictionViewSet(viewsets.ModelViewSet):
    serializer_class = PredictionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Prediction.objects.filter(user=self.request.user)

    def get_serializer_class(self):
        if self.action == 'create':
            return PredictionCreateSerializer
        return PredictionSerializer

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class UserProfileView(generics.RetrieveUpdateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileSerializer

    def get_object(self):
        return self.request.user

    def perform_update(self, serializer):
        serializer.save()


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

        return Response(
            {"detail": "Password updated successfully"},
            status=status.HTTP_200_OK
        )


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


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        return Response({"detail": "Logged out successfully. Please clear tokens on client side."}, status=status.HTTP_200_OK)


class ContactUsView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ContactUsSerializer(data=request.data)
        if serializer.is_valid():
            username = serializer.validated_data['username']
            user_email = serializer.validated_data['email']
            subject = serializer.validated_data['subject']
            body = serializer.validated_data['body']

            send_mail(
                subject=f"Contact Us: {subject}",
                message=f"From: {username} ({user_email})\n\n{body}",
                from_email='your-sender-email@gmail.com',
                recipient_list=['sabdalgelel@gmail.com'],
                fail_silently=False,
            )

            return Response({"detail": "Message sent successfully"}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def analyze_dna(request):
    print("===== START analyze_dna =====")
    print("User:", request.user.id)
    print("Request data:", dict(request.data))

    dna_sample_id = request.data.get('dna_sample_id')
    dna_sample = None

    # 1. لو بعتوا dna_sample_id → نجيب العينة من الداتابيز
    if dna_sample_id:
        try:
            dna_sample = DNASample.objects.get(id=dna_sample_id, user=request.user)
            print(f"Found existing DNASample ID: {dna_sample.id}")
        except DNASample.DoesNotExist:
            return Response({"error": "DNA Sample not found or not owned by you"}, status=404)

    # 2. تحديد مصدر البيانات (ملف جديد أو عينة محفوظة)
    if 'file' in request.FILES:
        file = request.FILES['file']
        sample_name = request.data.get('sample_name', file.name or f"Sample_{timezone.now().strftime('%Y-%m-%d_%H%M')}")

        try:
            df = pd.read_csv(file)
            print("New CSV file processed successfully")
            
            # حفظ الـ raw CSV في DNASample عشان نقدر نعيد التحليل بعدين
            sequence_data = {
                "sample_name": sample_name,
                "filename": file.name,
                "upload_method": "direct_analyze",
                "raw_csv": df.to_csv(index=False),  # حفظ الـ CSV كامل لإعادة الاستخدام
                "snps": df.to_dict(orient='records')[0] if not df.empty else {}
            }

            # لو مفيش dna_sample مرتبط → نحفظ واحد جديد
            if dna_sample is None:
                dna_sample = DNASample.objects.create(
                    user=request.user,
                    sequence_data=sequence_data
                )
                print(f"Created new DNASample ID: {dna_sample.id}")

        except Exception as e:
            return Response({"error": f"Invalid CSV file: {str(e)}"}, status=400)

    elif dna_sample and dna_sample.sequence_data:
        # حالة إعادة التحليل على عينة محفوظة (بدون ملف جديد)
        raw_csv = dna_sample.sequence_data.get('raw_csv', '')
        if not raw_csv:
            return Response({"error": "No stored CSV data available for re-analysis"}, status=400)
        
        try:
            df = pd.read_csv(io.StringIO(raw_csv))
            print("Loaded stored CSV from DNASample for re-analysis")
        except Exception as e:
            return Response({"error": f"Failed to load stored data: {str(e)}"}, status=400)
    else:
        return Response({"error": "No CSV file uploaded and no valid dna_sample_id provided"}, status=400)

    # 3. شغّل التحليل
    try:
        result = predict_from_csv(df)
    except Exception as e:
        return Response({"error": f"Prediction failed: {str(e)}"}, status=500)

    # 4. حفظ الـ Analysis مربوط بالـ dna_sample
    analysis = Analysis.objects.create(
        user=request.user,
        dna_sample=dna_sample,   # ← الربط ده هو اللي كان ناقص
        eye_results=result["eye"],
        hair_results=result["hair"],
        skin_results=result["skin"],
        overall_confidence=result["overall_confidence"]
    )

    # 5. حفظ الـ Prediction مربوط كمان
    Prediction.objects.create(
        user=request.user,
        dna_sample=dna_sample,   # ← الربط هنا كمان
        eye_color=result["summary"]["eye"],
        hair_color=result["summary"]["hair"],
        skin_tone=result["summary"]["skin"],
        eye_score=max(result["eye"].values()),
        hair_score=max(result["hair"].values()),
        skin_score=max(result["skin"].values()),
    )

    return Response({
        "success": True,
        "results": [result],
        "analysis_id": analysis.id,
        "dna_sample_id": dna_sample.id if dna_sample else None
    })


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_face(request):
    print("===== START generate_face =====")
    print("Creating ModelLog for user:", request.user.id)

    log = ModelLog.objects.create(
        dna_sample=None,
        status="processing",
        extra_data={
            "user_id": request.user.id,
            "request_time": str(timezone.now()),
            "type": "face_generation"
        }
    )
    print("Log created with ID:", log.id)

    data = request.data
    hair_color = data.get('hair_color')
    eye_color = data.get('eye_color')
    skin_tone = data.get('skin_tone')
    analysis_id = data.get('analysis_id')

    if not all([hair_color, eye_color, skin_tone, analysis_id]):
        log.status = "validation_error"
        log.error_message = "Missing required fields"
        log.save()
        print("Log updated to: validation_error")
        return Response(
            {"error": "Missing required fields: hair_color, eye_color, skin_tone, analysis_id"},
            status=status.HTTP_400_BAD_REQUEST
        )

    prompt = (
        f"Photorealistic 3D rendered portrait of a person with {hair_color} hair, "
        f"{eye_color} eyes, and {skin_tone} skin complexion. "
        "Front-facing view, studio lighting, clean neutral dark background, "
        "high quality, detailed facial features, head and shoulders only"
    )

    url = "https://api.airforce/v1/images/generations"
    payload = {
        "prompt": prompt,
        "model": "flux-2-dev",
        "n": 1,
        "size": "512x512"
    }
    headers = {"Content-Type": "application/json"}

    image_url = None
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=30)
        print("Airforce status code:", response.status_code)
        print("Airforce raw response:", response.text)

        response.raise_for_status()

        json_data = response.json()
        print("Parsed JSON:", json_data)

        if "data" not in json_data or not json_data["data"] or not isinstance(json_data["data"], list):
            raise ValueError("No valid 'data' array in API response")

        first_item = json_data["data"][0]
        if "url" not in first_item or not first_item["url"]:
            raise ValueError("No 'url' found in first data item")

        image_url = first_item["url"]

    except requests.exceptions.RequestException as req_err:
        error_msg = f"Airforce request failed: {str(req_err)}"
        print(error_msg)
        log.status = "failed"
        log.error_message = error_msg
        log.save()
        print("Log updated to: failed (request error)")
        return Response({"error": error_msg}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    except (ValueError, KeyError, IndexError) as api_err:
        error_msg = f"API response parsing failed: {str(api_err)}"
        print(error_msg)
        log.status = "failed"
        log.error_message = error_msg
        log.save()
        print("Log updated to: failed (parsing error)")
        return Response({"error": error_msg}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    except Exception as unexpected_err:
        import traceback
        error_msg = f"Unexpected error in generate_face: {str(unexpected_err)}\n{traceback.format_exc()}"
        print(error_msg)
        log.status = "failed"
        log.error_message = error_msg
        log.save()
        print("Log updated to: failed (unexpected)")
        return Response({"error": "Internal server error"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    try:
        analysis = Analysis.objects.get(id=analysis_id, user=request.user)
        log.dna_sample = analysis.dna_sample
        log.save()
        print("Log updated with dna_sample from analysis")
    except Analysis.DoesNotExist:
        log.status = "validation_error"
        log.error_message = "Analysis not found or not owned by user"
        log.save()
        print("Log updated to: validation_error")
        return Response(
            {"error": "Analysis not found or not owned by you"},
            status=status.HTTP_404_NOT_FOUND
        )

    GeneratedFace.objects.create(
        analysis=analysis,
        image_url=image_url,
        prompt=prompt
    )

    log.status = "success"
    log.extra_data.update({
        "analysis_id": analysis_id,
        "image_url": image_url,
        "execution_time": str(timezone.now() - log.created_at)
    })
    log.save()
    print("Log updated to: success")

    return Response({
        "success": True,
        "image_url": image_url,
        "prompt": prompt,
        "analysis_id": analysis_id
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def analysis_history(request):
    analyses = Analysis.objects.filter(user=request.user).order_by('-created_at')
    data = []
    for analysis in analyses:
        face = GeneratedFace.objects.filter(analysis=analysis).first()
        sample_name = "Unknown Sample"
        if analysis.dna_sample:
            sequence_data = analysis.dna_sample.sequence_data
            sample_name = sequence_data.get("sample_name") or sequence_data.get("sample_id") or sequence_data.get("filename") or f"Sample #{analysis.id}"
        data.append({
            "id": analysis.id,
            "created_at": analysis.created_at.isoformat(),
            "eye_results": analysis.eye_results,
            "hair_results": analysis.hair_results,
            "skin_results": analysis.skin_results,
            "overall_confidence": analysis.overall_confidence,
            "face_image_url": face.image_url if face else None,
            "sample_name": sample_name
        })
    return Response({"results": data})


class ModelLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = ModelLog
        fields = ['id', 'status', 'error_message', 'created_at', 'extra_data']
        read_only_fields = fields


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def model_logs(request):
    logs = ModelLog.objects.filter(dna_sample__user=request.user).order_by('-created_at')[:20]
    
    serializer = ModelLogSerializer(logs, many=True)
    return Response({
        "success": True,
        "logs": serializer.data
    })


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_analysis(request, analysis_id):
    try:
        analysis = Analysis.objects.get(id=analysis_id, user=request.user)
        analysis.delete()
        return Response({"success": True, "message": "Analysis deleted successfully"}, status=status.HTTP_200_OK)
    except Analysis.DoesNotExist:
        return Response({"error": "Analysis not found or not owned by you"}, status=status.HTTP_404_NOT_FOUND)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def clear_all_analyses(request):
    Analysis.objects.filter(user=request.user).delete()
    return Response(
        {"success": True, "message": "All analyses cleared successfully"},
        status=status.HTTP_200_OK
    )