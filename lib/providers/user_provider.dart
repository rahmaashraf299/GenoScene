import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionCategory { government, individual }

class UserProvider extends ChangeNotifier {
  String? _username;
  String? _email;
  String? _profilePicture;
  bool _isGuest = false;
  bool _isLoading = false;
  bool _isReportsLoading = false;
  bool _isFaceLoading = false;
  Map<String, String> _fileNamesCache = {};
  Map<String, String> get fileNamesCache => _fileNamesCache;

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadAllCachedNames();
  }

  Future<void> saveFileNameLocally(String id, String name) async {
    _fileNamesCache[id] = name;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dna_sample_name_$id', name);
    } catch (e) {
      debugPrint("Error saving name to prefs: $e");
    }
  }

  Future<void> _loadAllCachedNames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('dna_sample_name_'));
      for (var key in keys) {
        final id = key.replaceFirst('dna_sample_name_', '');
        final name = prefs.getString(key);
        if (name != null && name.isNotEmpty) {
          _fileNamesCache[id] = name;
        }
      }
      notifyListeners();
      debugPrint("Loaded ${_fileNamesCache.length} names from cache.");
    } catch (e) {
      debugPrint("Error loading names from prefs: $e");
    }
  }

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
        _profilePicture = userProfile['profile_picture'];
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

  // ─── الدالة المعدلة بناءً على طلب الباك-إند ──────────────────────────────
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
          "Accept": "application/json",
        },
      );

      // طباعة الـ JSON كاملة في الكونسول لتتبع المشاكل
      print("Full analysis-history JSON: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> historyList = data['results'] ?? [];
        
        // تحويل البيانات لـ ReportItem
        _reports = historyList.map((json) => ReportItem.fromJson(json)).toList();
        
        // مزامنة الأسماء اللي جاية من السيرفر مع الكاش المحلي
        for (var report in _reports) {
          if (report.sampleName.isNotEmpty && !report.sampleName.startsWith('Report #')) {
            _fileNamesCache[report.id] = report.sampleName;
          }
        }
        
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
    _reports.insert(0, report);
    notifyListeners();
  }

  Future<void> removeReport(String id) async {
    // حذف سريع من الواجهة (Optimistic Delete)
    _reports.removeWhere((r) => r.id == id);
    _fileNamesCache.remove(id);
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      final url = "https://naida-pterodactylous-chillingly.ngrok-free.dev/api/analysis/$id/delete/";

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "69420",
        },
      );
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        debugPrint("Server delete failed for $id: ${response.statusCode}");
        // في حالة الفشل ممكن تعيدي تحميل التقارير للتأكد
        loadReports();
      } else {
        print("Report $id deleted successfully from server.");
      }
    } catch (e) {
      debugPrint("Delete process error: $e");
    }
  }

  Future<void> clearAllReports() async {
    _reports = [];
    _fileNamesCache.clear();
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse("https://naida-pterodactylous-chillingly.ngrok-free.dev/api/analyses/clear-all/"),
        headers: {
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "69420",
        },
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        debugPrint("Server clear all failed: ${response.statusCode}");
        loadReports();
      }
    } catch (e) {
      debugPrint("Clear all error: $e");
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

          int index = _reports.indexWhere((r) => r.id.toString() == analysisId.toString());
          
          if (index != -1) {
            _reports[index] = _reports[index].copyWith(
              faceImageUrl: newImageUrl,
              facePrompt: newPrompt,
            );
            print("Success! Image updated in Provider for ID: $analysisId");
          }
          
          _isFaceLoading = false;
          notifyListeners();
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