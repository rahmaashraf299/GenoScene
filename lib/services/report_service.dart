import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/report_item.dart';
import 'auth_service.dart';

class ReportService {
  static Future<List<ReportItem>> loadReports() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse("${ApiConfig.apiUrl}${ApiConfig.analysisHistoryEndpoint}"),
        headers: ApiConfig.authMultipartHeaders(token!),
      ).timeout(ApiConfig.defaultTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);

        final List<ReportItem> reports = decoded.map((item) {
          // Fix relative URLs in history data
          if (item['face_image_url'] != null &&
              item['face_image_url'].toString().isNotEmpty &&
              !item['face_image_url'].toString().startsWith('http')) {
            item['face_image_url'] = item['face_image_url'].toString().startsWith('/')
                ? "${ApiConfig.baseUrl}${item['face_image_url']}"
                : "${ApiConfig.baseUrl}/${item['face_image_url']}";
          }
          return ReportItem.fromJson(item);
        }).toList();

        return reports;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<void> addReport(ReportItem report) async {}

  static Future<void> deleteReport(String id) async {}
}
