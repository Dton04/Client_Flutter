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
    // return 'http://26.45.246.74:7979/api/v1';
  }

  // Image Base URL (Root of the server)
  static String get imageBaseUrl {
    // Remove /api/v1 from baseUrl
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.host}:${uri.port}';
  }

  // Helper to get full image URL
  static String getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http') || url.startsWith('https')) return url;

    // Clean url if it starts with /
    final cleanUrl = url.startsWith('/') ? url : '/$url';
    return '$imageBaseUrl$cleanUrl';
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

  // Exercise endpoints
  static const String exercises = '/exercises';
  static String get exercisesUrl => '$baseUrl$exercises';

  // Plan endpoints
  static const String plans = '/plans';
  static String get plansUrl => '$baseUrl$plans';
  static String planSchedulesUrl(int planId) =>
      '$baseUrl$plans/$planId/schedules';
  static String scheduleExercisesUrl(int scheduleId) =>
      '$baseUrl$plans/schedules/$scheduleId/exercises';
  static String planExercisesUrl(int planExerciseId) =>
      '$baseUrl$plans/exercises/$planExerciseId';

  // Stats endpoints
  static const String dashboardStats = '/stats/dashboard';
  static const String weightChart = '/stats/weight-chart';

  // Workout tracking endpoints
  static const String workouts = '/workouts';
  static const String workoutHistory = '/workouts/history';

  // Stats Full URLs
  static String get dashboardStatsUrl => '$baseUrl$dashboardStats';
  static String get weightChartUrl => '$baseUrl$weightChart';

  // Workout tracking Full URLs
  static String get workoutsUrl => '$baseUrl$workouts';
  static String get workoutHistoryUrl => '$baseUrl$workoutHistory';
  static String workoutHistoryDetailUrl(int historyId) =>
      '$baseUrl$workoutHistory/$historyId';

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
