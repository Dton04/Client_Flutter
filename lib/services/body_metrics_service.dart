import '../config/api_config.dart';
import '../models/body_metrics_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class BodyMetricsService {
  // Add new body metrics
  static Future<Map<String, dynamic>> addBodyMetrics({
    required double weight,
    required double height,
    double? bodyFatPercentage,
  }) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final body = {
        'weight': weight,
        'height': height,
        if (bodyFatPercentage != null) 'body_fat_percentage': bodyFatPercentage,
      };

      final response = await ApiService.post(
        url: ApiConfig.bodyMetricsUrl,
        body: body,
        headers: ApiConfig.headersWithToken(token),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get body metrics history (if needed later)
  static Future<List<BodyMetricsModel>> getBodyMetricsHistory() async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await ApiService.get(
        url: ApiConfig.bodyMetricsUrl,
        headers: ApiConfig.headersWithToken(token),
      );

      // Assuming response is a list
      final List<dynamic> metricsJson =
          response['data'] ?? response['metrics'] ?? [];
      return metricsJson
          .map((json) => BodyMetricsModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
