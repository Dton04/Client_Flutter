import 'plan_exercise_model.dart';

class PlanScheduleModel {
  final int? scheduleId; // Nullable if creating new
  final String dayOfWeek;
  final String title;
  final List<PlanExerciseModel> exercises;

  PlanScheduleModel({
    this.scheduleId,
    required this.dayOfWeek,
    required this.title,
    this.exercises = const [],
  });

  factory PlanScheduleModel.fromJson(Map<String, dynamic> json) {
    var exercisesList = <PlanExerciseModel>[];
    if (json['exercises'] != null) {
      exercisesList = (json['exercises'] as List)
          .map((e) => PlanExerciseModel.fromJson(e))
          .toList();
    }

    return PlanScheduleModel(
      scheduleId: json['schedule_id'] as int?,
      dayOfWeek: json['day_of_week'] as String,
      title: json['title'] as String,
      exercises: exercisesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule_id': scheduleId,
      'day_of_week': dayOfWeek,
      'title': title,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  PlanScheduleModel copyWith({
    int? scheduleId,
    String? dayOfWeek,
    String? title,
    List<PlanExerciseModel>? exercises,
  }) {
    return PlanScheduleModel(
      scheduleId: scheduleId ?? this.scheduleId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      title: title ?? this.title,
      exercises: exercises ?? this.exercises,
    );
  }
}
