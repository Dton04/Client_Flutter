class UserProfileModel {
  final int userId;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? gender;
  final String? fitnessGoal;
  final double? weight;
  final double? height;
  final int? age;
  final double? bmi;
  final double? bodyFatPercentage;
  final DateTime? joinedAt;

  UserProfileModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.gender,
    this.fitnessGoal,
    this.weight,
    this.height,
    this.age,
    this.bmi,
    this.bodyFatPercentage,
    this.joinedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Parse metrics object if it exists
    final metrics = json['metrics'] as Map<String, dynamic>?;

    return UserProfileModel(
      userId: json['user_id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      gender: json['gender'] as String?,
      fitnessGoal: metrics?['fitness_goal'] as String?,
      weight: metrics?['weight'] != null
          ? (metrics!['weight'] as num).toDouble()
          : null,
      height: metrics?['height'] != null
          ? (metrics!['height'] as num).toDouble()
          : null,
      age: json['age'] as int?,
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      bodyFatPercentage: json['body_fat_percentage'] != null
          ? (json['body_fat_percentage'] as num).toDouble()
          : null,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'gender': gender,
      'fitness_goal': fitnessGoal,
      'weight': weight,
      'height': height,
      'age': age,
      'bmi': bmi,
      'body_fat_percentage': bodyFatPercentage,
      'joined_at': joinedAt?.toIso8601String(),
    };
  }

  UserProfileModel copyWith({
    int? userId,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? gender,
    String? fitnessGoal,
    double? weight,
    double? height,
    int? age,
    double? bmi,
    double? bodyFatPercentage,
    DateTime? joinedAt,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      bmi: bmi ?? this.bmi,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
