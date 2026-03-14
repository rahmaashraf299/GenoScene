import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report_item.dart';
import '../services/report_service.dart';

enum SubscriptionCategory { government, individual }

class UserProvider extends ChangeNotifier {
  String? _username;
  String? _email;
  String? _profilePicture;
  bool _isGuest = false;
  bool _isLoading = false;
  bool _isReportsLoading = false;
  bool _isFaceLoading = false;
  
  // Subscription State
  String? _currentPlan;
  SubscriptionCategory? _planCategory;
  int _remainingReports = 0;

  // Analysis History
  List<ReportItem> _reports = [];

  String? get username => _username;
  String? get email => _email;
  String? get profilePicture => _profilePicture;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  bool get isReportsLoading => _isReportsLoading;
  bool get isFaceLoading => _isFaceLoading;
  String? get currentPlan => _currentPlan;
  SubscriptionCategory? get planCategory => _planCategory;
  int get remainingReports => _remainingReports;
  bool get isPremium => _currentPlan != null;
  List<ReportItem> get reports => _reports;

  void setGuestMode(bool value) {
    _isGuest = value;
    notifyListeners();
  }

  void updateSubscription(String plan, SubscriptionCategory category, int reports) {
    _currentPlan = plan;
    _planCategory = category;
    _remainingReports = reports;
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userProfile = await AuthService.getUserProfile();
      if (userProfile != null) {
        _username = userProfile['username'];
        _email = userProfile['email'];
        // Ensure profile_picture is a full URL if it exists
        // Depending on backend, it might be partial or full.
        // For now, assuming it returns what we need or null.
        _profilePicture = userProfile['profile_picture'];

        // Also update AuthService static listener for backward compatibility if needed
        AuthService.updateProfilePic(_profilePicture);
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateUser(String username, String email) {
    _username = username;
    _email = email;
    notifyListeners();
  }

  void clearUser() {
    _username = null;
    _email = null;
    _profilePicture = null;
    _isGuest = false;
    _currentPlan = null;
    _planCategory = null;
    _remainingReports = 0;
    _reports = [];
    notifyListeners();
  }

  Future<void> loadReports() async {
    _isReportsLoading = true;
    notifyListeners();
    
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse("https://naida-pterodactylous-chillingly.ngrok-free.dev/api/analysis-history/"),
        headers: {
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "69420",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // التعديل الجوهري: الدخول لـ results وتجنب TypeError
        final List<dynamic> historyList = data['results'] ?? [];
        
        // تحويل كل عنصر لـ ReportItem باستخدام الـ factory model بتاعك
        _reports = historyList.map((json) => ReportItem.fromJson(json)).toList();
        
        print("History Synced: ${_reports.length} reports found.");
      } else {
        print("Failed to load history: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading reports: $e");
    } finally {
      _isReportsLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReport(ReportItem report) async {
    // بنضيفه محلياً فوراً عشان اليوزر يشوفه
    _reports.insert(0, report);
    notifyListeners();
    
    // ملاحظة: الرفع الفعلي بيحصل في سكرينة الـ Upload 
    // فمش محتاجين ننادي ReportService هنا لو إنتِ رفعتيه خلاص
  }

  Future<void> removeReport(String id) async {
    final originalReports = List<ReportItem>.from(_reports);
    _reports.removeWhere((r) => r.id == id);
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse("https://naida-pterodactylous-chillingly.ngrok-free.dev/api/analysis-history/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception("Failed to delete");
      }
    } catch (e) {
      // لو فشل المسح في السيرفر، بنرجع اللستة زي ما كانت
      _reports = originalReports;
      notifyListeners();
      print("Delete failed: $e");
    }
  }

  Future<bool> generateFaceAI({
  required String analysisId,
  required String hair,
  required String eye,
  required String skin,
}) async {
  _isFaceLoading = true;
  notifyListeners();

  try {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse("https://naida-pterodactylous-chillingly.ngrok-free.dev/api/generate-face/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "69420",
      },
      body: jsonEncode({
        "hair_color": hair.toLowerCase(),
        "eye_color": eye.toLowerCase(),
        "skin_tone": skin.toLowerCase(),
        "analysis_id": int.tryParse(analysisId) ?? analysisId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final newImageUrl = data['image_url'];
        final newPrompt = data['prompt'];

        // --- التعديل السحري هنا ---
        // بنحول الـ ID لـ String في المقارنة عشان نضمن إنه يلاقيه سواء كان رقم أو نص
        int index = _reports.indexWhere((r) => r.id.toString() == analysisId.toString());
        
        if (index != -1) {
          _reports[index] = _reports[index].copyWith(
            faceImageUrl: newImageUrl,
            facePrompt: newPrompt,
          );
          print("Success! Image updated in Provider for ID: $analysisId");
        } else {
          print("Warning: Report ID $analysisId not found in local list.");
          // لو مش موجود في اللستة، ضيفيه كريبورت جديد مؤقتاً عشان يظهر في الشاشة
        }
        
        _isFaceLoading = false;
        notifyListeners(); // ده اللي هيخلي الـ Consumer في الشاشة ينطق ويظهر الصورة
        return true;
      }
    }
  } catch (e) {
    print("Provider Error: $e");
  } finally {
    _isFaceLoading = false;
    notifyListeners();
  }
  return false;
}
}
