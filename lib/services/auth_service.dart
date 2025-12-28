import '../config/api_config.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  // Register new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await ApiService.post(
        url: ApiConfig.registerUrl,
        body: {'email': email, 'password': password, 'full_name': fullName},
        headers: ApiConfig.headers,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Login user
  static Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        url: ApiConfig.loginUrl,
        body: {'email': email, 'password': password},
        headers: ApiConfig.headers,
      );

      // Parse response to AuthResponseModel
      final authResponse = AuthResponseModel.fromJson(response);

      // Save tokens and user data
      await StorageService.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      await StorageService.saveUser(authResponse.user);

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Forgot password - Send OTP
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await ApiService.post(
        url: ApiConfig.forgotPasswordUrl,
        body: {'email': email},
        headers: ApiConfig.headers,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Reset password with OTP
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post(
        url: ApiConfig.resetPasswordUrl,
        body: {
          'email': email,
          'otp_code': otpCode,
          'new_password': newPassword,
        },
        headers: ApiConfig.headers,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Change password (authenticated)
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await ApiService.put(
        url: ApiConfig.changePasswordUrl,
        body: {'old_password': oldPassword, 'new_password': newPassword},
        headers: ApiConfig.headersWithToken(token),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  static Future<void> logout() async {
    await StorageService.clearAuthData();
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return StorageService.isLoggedIn();
  }

  // Get current user
  static UserModel? getCurrentUser() {
    return StorageService.getUser();
  }
}
