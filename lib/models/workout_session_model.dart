import 'exercise_session_model.dart';
import 'plan_schedule_model.dart';
import 'plan_exercise_model.dart';

class WorkoutSessionModel {
  final PlanScheduleModel schedule;
  final int? planScheduleId;
  final DateTime startTime;
  final List<ExerciseSessionModel> exercises;
  String? notes;

  WorkoutSessionModel({
    required this.schedule,
    this.planScheduleId,
    DateTime? startTime,
    String? notes,
  }) : startTime = startTime ?? DateTime.now(),
       notes = notes,
       exercises = _initializeExercises(schedule.exercises);

  static List<ExerciseSessionModel> _initializeExercises(
    List<PlanExerciseModel> planExercises,
  ) {
    return planExercises.map((planEx) {
      return ExerciseSessionModel(
        exerciseId: planEx.exerciseId,
        exerciseName: planEx.exerciseName ?? 'Unknown Exercise',
        exerciseImageUrl: planEx.exerciseImageUrl,
        targetSets: planEx.targetSets,
        targetReps: planEx.targetReps,
        restTime: planEx.targetRestTime,
      );
    }).toList();
  }

  int get completedExercises {
    return exercises.where((e) => e.isComplete).length;
  }

  int get totalExercises {
    return exercises.length;
  }

  Duration get duration {
    return DateTime.now().difference(startTime);
  }

  int get durationMinutes {
    return duration.inMinutes;
  }

  bool get isComplete {
    return completedExercises == totalExercises;
  }

  WorkoutSessionModel copyWith({
    PlanScheduleModel? schedule,
    int? planScheduleId,
    DateTime? startTime,
    List<ExerciseSessionModel>? exercises,
    String? notes,
  }) {
    final model = WorkoutSessionModel(
      schedule: schedule ?? this.schedule,
      planScheduleId: planScheduleId ?? this.planScheduleId,
      startTime: startTime ?? this.startTime,
      notes: notes ?? this.notes,
    );

    // Replace exercises if provided
    if (exercises != null) {
      model.exercises.clear();
      model.exercises.addAll(exercises);
    }

    return model;
  }

  // Convert to API format for logging workout
  Map<String, dynamic> toApiRequest() {
    return {
      'plan_schedule_id': planScheduleId,
      'performed_at': DateTime.now().toIso8601String(),
      'duration_minutes': durationMinutes,
      'notes': notes,
      'details': exercises
          .where(
            (e) => e.completedSets > 0,
          ) // Only include exercises with at least 1 set
          .map((e) => e.toApiDetail())
          .toList(),
    };
  }
}
