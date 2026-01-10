class WorkoutHistoryModel {
  final int historyId;
  final DateTime performedAt;
  final String? planName;
  final int? durationMinutes;
  final String? notes;

  WorkoutHistoryModel({
    required this.historyId,
    required this.performedAt,
    this.planName,
    this.durationMinutes,
    this.notes,
  });

  factory WorkoutHistoryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryModel(
      historyId: json['history_id'],
      performedAt: DateTime.parse(json['performed_at']),
      planName: json['plan_name'],
      durationMinutes: json['duration_minutes'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'history_id': historyId,
      'performed_at': performedAt.toIso8601String(),
      'plan_name': planName,
      'duration_minutes': durationMinutes,
      'notes': notes,
    };
  }

  // Helper to get day of week (0 = Monday, 6 = Sunday)
  int get dayOfWeek {
    // DateTime.weekday returns 1-7 (Monday-Sunday)
    // We want 0-6 (Monday-Sunday)
    return performedAt.weekday - 1;
  }

  // Helper to check if workout was performed on a specific date
  bool isOnDate(DateTime date) {
    return performedAt.year == date.year &&
        performedAt.month == date.month &&
        performedAt.day == date.day;
  }
}
