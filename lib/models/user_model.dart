import 'dart:convert';

class UserModel {
  final int userId;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String role;

  UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.role,
  });

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'USER',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role,
    };
  }

  // To JSON String
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // From JSON String
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  // Copy with
  UserModel copyWith({
    int? userId,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? role,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, email: $email, fullName: $fullName, avatarUrl: $avatarUrl, role: $role)';
  }
}
