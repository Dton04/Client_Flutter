class DashboardStatsModel {
  final int totalWorkouts;
  final int totalMinutes;
  final int currentStreak;

  DashboardStatsModel({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.currentStreak,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalWorkouts: json['total_workouts'] ?? 0,
      totalMinutes: json['total_minutes'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_workouts': totalWorkouts,
      'total_minutes': totalMinutes,
      'current_streak': currentStreak,
    };
  }
}
