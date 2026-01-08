import '../config/api_config.dart';
import '../models/exercise_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class ExerciseService {
  // 19. Get Exercises List (Filter)
  static Future<Map<String, dynamic>> getExercises({
    dynamic muscleGroupId, // Changed to dynamic to support both int and String IDs
    String? difficulty,
    int page = 1,
    int limit = 10,
    String? keyword,
  }) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      } // Đã đóng ngoặc đúng cho if

      // Build query parameters
      String queryParams = '?page=$page&limit=$limit';
      if (muscleGroupId != null) queryParams += '&muscle_group_id=$muscleGroupId';
      if (difficulty != null) queryParams += '&difficulty=$difficulty';
      if (keyword != null && keyword.isNotEmpty) queryParams += '&keyword=$keyword';

      final response = await ApiService.get(
        url: '${ApiConfig.exercisesUrl}$queryParams',
        headers: ApiConfig.headersWithToken(token),
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // 21. Get Muscle Groups
  static Future<List<dynamic>> getMuscleGroups() async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      // Assuming endpoint is /muscle-groups. Adjust if your API is different (e.g. /exercises/muscle-groups)
      final response = await ApiService.get(
        url: '${ApiConfig.baseUrl}/muscle-groups', 
        headers: ApiConfig.headersWithToken(token),
      );

      return response as List<dynamic>;
    } catch (e) {
      // Return empty list or rethrow depending on needs. 
      // Rethrowing allows UI to handle error.
      print('Error fetching muscle groups: $e');
      return [];
    }
  }

  // 20. Get Exercise Detail
  static Future<ExerciseModel> getExerciseDetail(int exerciseId) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await ApiService.get(
        url: '${ApiConfig.exercisesUrl}/$exerciseId',
        headers: ApiConfig.headersWithToken(token),
      );

      return ExerciseModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}