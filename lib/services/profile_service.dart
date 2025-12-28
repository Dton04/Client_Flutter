import '../config/api_config.dart';
import '../models/user_profile_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProfileService {
  // Get user profile
  static Future<UserProfileModel> getUserProfile() async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await ApiService.get(
        url: ApiConfig.userProfileUrl,
        headers: ApiConfig.headersWithToken(token),
      );

      return UserProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? gender,
    String? fitnessGoal,
  }) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (avatarUrl != null) body['avatar_url'] = avatarUrl;
      if (gender != null) body['gender'] = gender;
      if (fitnessGoal != null) body['fitness_goal'] = fitnessGoal;

      final response = await ApiService.put(
        url: ApiConfig.userProfileUrl,
        body: body,
        headers: ApiConfig.headersWithToken(token),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
