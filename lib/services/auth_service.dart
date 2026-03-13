import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String _tokenKey = 'auth_token';

  // Notifier for profile picture URL
  static final ValueNotifier<String?> profilePicNotifier =
      ValueNotifier<String?>(null);

  // Helper to update profile pic
  static void updateProfilePic(String? url) {
    profilePicNotifier.value = url;
  }

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Remove token (Logout)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Get User Profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final token = await getToken();
    if (token == null) return null;

    final String baseUrl =
        "https://naida-pterodactylous-chillingly.ngrok-free.dev/api";

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/me/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "69420",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint("Failed to load profile: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      return null;
    }
  }
}
