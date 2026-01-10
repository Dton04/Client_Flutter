import '../config/api_config.dart';
import '../models/dashboard_stats_model.dart';
import '../models/workout_history_model.dart';
import '../models/weight_chart_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class TrackingService {
  // Get dashboard statistics
  static Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await ApiService.get(
        url: ApiConfig.dashboardStatsUrl,
        headers: ApiConfig.headersWithToken(token),
      );

      return DashboardStatsModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get workout history with optional month/year filters
  static Future<List<WorkoutHistoryModel>> getWorkoutHistory({
    int? month,
    int? year,
  }) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      // Build query parameters
      String url = ApiConfig.workoutHistoryUrl;
      List<String> queryParams = [];

      if (month != null) {
        queryParams.add('month=$month');
      }
      if (year != null) {
        queryParams.add('year=$year');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await ApiService.get(
        url: url,
        headers: ApiConfig.headersWithToken(token),
      );

      // Response is { "workouts": [...] }
      final List<dynamic> workoutsJson = response['workouts'] ?? [];
      return workoutsJson
          .map((json) => WorkoutHistoryModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get weight chart data
  static Future<List<WeightChartModel>> getWeightChart({
    String range = '3months',
  }) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final url = '${ApiConfig.weightChartUrl}?range=$range';

      final response = await ApiService.get(
        url: url,
        headers: ApiConfig.headersWithToken(token),
      );

      // Response is an array of weight data points
      final List<dynamic> chartDataJson = response is List ? response : [];
      return chartDataJson
          .map((json) => WeightChartModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Log a new workout
  static Future<Map<String, dynamic>> logWorkout({
    int? planScheduleId,
    required DateTime performedAt,
    required int durationMinutes,
    String? notes,
    required List<Map<String, dynamic>> details,
  }) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await ApiService.post(
        url: ApiConfig.workoutsUrl,
        body: {
          'plan_schedule_id': planScheduleId,
          'performed_at': performedAt.toIso8601String(),
          'duration_minutes': durationMinutes,
          'notes': notes,
          'details': details,
        },
        headers: ApiConfig.headersWithToken(token),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get workout history detail
  static Future<Map<String, dynamic>> getWorkoutHistoryDetail(
    int historyId,
  ) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await ApiService.get(
        url: ApiConfig.workoutHistoryDetailUrl(historyId),
        headers: ApiConfig.headersWithToken(token),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Delete workout history
  static Future<void> deleteWorkoutHistory(int historyId) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      await ApiService.delete(
        url: ApiConfig.workoutHistoryDetailUrl(historyId),
        headers: ApiConfig.headersWithToken(token),
      );
    } catch (e) {
      rethrow;
    }
  }
}
