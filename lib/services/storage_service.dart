import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Save access token
  static Future<bool> saveAccessToken(String token) async {
    return await prefs.setString(AppConstants.keyAccessToken, token);
  }

  // Get access token
  static String? getAccessToken() {
    return prefs.getString(AppConstants.keyAccessToken);
  }

  // Save refresh token
  static Future<bool> saveRefreshToken(String token) async {
    return await prefs.setString(AppConstants.keyRefreshToken, token);
  }

  // Get refresh token
  static String? getRefreshToken() {
    return prefs.getString(AppConstants.keyRefreshToken);
  }

  // Save both tokens
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
  }

  // Save user data
  static Future<bool> saveUser(UserModel user) async {
    return await prefs.setString(AppConstants.keyUser, user.toJsonString());
  }

  // Get user data
  static UserModel? getUser() {
    final userJson = prefs.getString(AppConstants.keyUser);
    if (userJson == null) return null;

    try {
      return UserModel.fromJsonString(userJson);
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  // Clear all auth data (logout)
  static Future<void> clearAuthData() async {
    await prefs.remove(AppConstants.keyAccessToken);
    await prefs.remove(AppConstants.keyRefreshToken);
    await prefs.remove(AppConstants.keyUser);
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await prefs.clear();
  }
}
