class ApiConfig {
  // Base URL for API - automatically detects platform
  // For Android Emulator: uses 10.0.2.2
  // For iOS Simulator: uses localhost
  // For real devices: uncomment and use your computer's IP address
  static String get baseUrl {
    // Uncomment this line and replace with your computer's IP for real devices
    // return 'http://192.168.1.100:7979/api/v1';

    // For emulator/simulator
    return 'http://10.0.2.2:7979/api/v1';
  }

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // Full URLs
  static String get registerUrl => '$baseUrl$register';
  static String get loginUrl => '$baseUrl$login';
  static String get forgotPasswordUrl => '$baseUrl$forgotPassword';
  static String get resetPasswordUrl => '$baseUrl$resetPassword';
  static String get changePasswordUrl => '$baseUrl$changePassword';

  // Upload endpoints
  static const String uploadImage = '/upload/image';

  // User & Profile endpoints
  static const String userProfile = '/users/profile';
  static const String bodyMetrics = '/users/body-metrics';

  // Upload Full URLs
  static String get uploadImageUrl => '$baseUrl$uploadImage';

  // User & Profile Full URLs
  static String get userProfileUrl => '$baseUrl$userProfile';
  static String get bodyMetricsUrl => '$baseUrl$bodyMetrics';

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> headersWithToken(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Headers for multipart requests (no Content-Type, let http package set it)
  static Map<String, String> headersWithTokenNoContentType(String token) => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
