import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final String role;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.role,
  });

  // From JSON
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      role: json['role'] as String,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      'role': role,
    };
  }

  @override
  String toString() {
    return 'AuthResponseModel(accessToken: $accessToken, refreshToken: $refreshToken, user: $user, role: $role)';
  }
}
