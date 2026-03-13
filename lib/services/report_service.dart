import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report_item.dart';
import 'auth_service.dart';

class ReportService {
  static const String _historyUrl = "https://naida-pterodactylous-chillingly.ngrok-free.dev/api/analysis-history/";

  static Future<List<ReportItem>> loadReports() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(_historyUrl),
        headers: {
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "69420",
          "Accept": "application/json",
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        const baseUrl = "https://naida-pterodactylous-chillingly.ngrok-free.dev";
        
        final List<ReportItem> reports = decoded.map((item) {
          // Fix relative URLs in history data
          if (item['face_image_url'] != null && 
              item['face_image_url'].toString().isNotEmpty && 
              !item['face_image_url'].toString().startsWith('http')) {
            item['face_image_url'] = item['face_image_url'].toString().startsWith('/') 
                ? "$baseUrl${item['face_image_url']}" 
                : "$baseUrl/${item['face_image_url']}";
          }
          return ReportItem.fromJson(item);
        }).toList();
        
        return reports;
      } else {
        print("Error fetching history: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error loading reports: $e");
      return [];
    }
  }

  static Future<void> addReport(ReportItem report) async {
    // Reports are added via the analysis endpoint, 
    // but we can keep this for local-only mocks if needed.
    // In this integration, we rely on the backend to persist history.
  }

  static Future<void> deleteReport(String id) async {
    // Backend deletion endpoint not specified, keeping as placeholder.
  }
}
