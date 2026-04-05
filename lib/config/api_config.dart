/// Centralized API configuration for GenoScene.
/// All backend URLs and headers are defined here — never hardcode them in screens.
abstract class ApiConfig {
  static const String baseUrl =
      "https://naida-pterodactylous-chillingly.ngrok-free.dev";
  static const String apiUrl = "$baseUrl/api";

  /// Header required to bypass ngrok's browser warning page.
  static const Map<String, String> ngrokHeaders = {
    "ngrok-skip-browser-warning": "69420",
  };

  static const Duration defaultTimeout = Duration(seconds: 15);

  // ── Endpoint Paths ──
  static const String tokenEndpoint = "/token/";
  static const String registerEndpoint = "/register/";
  static const String profileEndpoint = "/me/";
  static const String changePasswordEndpoint = "/me/change-password/";
  static const String analyzeEndpoint = "/analyze/";
  static const String analysisHistoryEndpoint = "/analysis-history/";
  static String analysisDeleteEndpoint(String id) => "/analysis/$id/delete/";
  static const String clearAllEndpoint = "/analyses/clear-all/";
  static const String generateFaceEndpoint = "/generate-face/";
  static const String contactUsEndpoint = "/contact-us/";

  /// Constructs full media URL from a relative path.
  static String mediaUrl(String relativePath) {
    final cleanPath =
        relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    return "$baseUrl/media/$cleanPath";
  }

  /// Common auth + ngrok headers for JSON requests.
  static Map<String, String> authHeaders(String token) => {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        ...ngrokHeaders,
      };

  /// Auth headers without Content-Type (for multipart requests).
  static Map<String, String> authMultipartHeaders(String token) => {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        ...ngrokHeaders,
      };
}
