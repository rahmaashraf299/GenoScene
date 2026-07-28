/// Centralized API configuration for GenoScene.
///
/// Set the backend URL at run/build time:
/// flutter run --dart-define=GENOSCENE_API_URL=http://127.0.0.1:8000
abstract class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'GENOSCENE_API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String apiUrl = '$baseUrl/api';

  /// Header used when the configured development URL is served through ngrok.
  static const Map<String, String> ngrokHeaders = {
    'ngrok-skip-browser-warning': '69420',
  };

  static const Duration defaultTimeout = Duration(seconds: 15);

  static const String tokenEndpoint = '/token/';
  static const String registerEndpoint = '/register/';
  static const String profileEndpoint = '/me/';
  static const String changePasswordEndpoint = '/me/change-password/';
  static const String analyzeEndpoint = '/analyze/';
  static const String analysisHistoryEndpoint = '/analysis-history/';
  static String analysisDeleteEndpoint(String id) => '/analysis/$id/delete/';
  static const String clearAllEndpoint = '/analyses/clear-all/';
  static const String generateFaceEndpoint = '/generate-face/';
  static const String contactUsEndpoint = '/contact-us/';

  static String mediaUrl(String relativePath) {
    final cleanPath = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;
    return '$baseUrl/media/$cleanPath';
  }

  static Map<String, String> authHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    ...ngrokHeaders,
  };

  static Map<String, String> authMultipartHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
    ...ngrokHeaders,
  };
}
