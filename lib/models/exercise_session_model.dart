import 'set_model.dart';

class ExerciseSessionModel {
  final int exerciseId;
  final String exerciseName;
  final String? exerciseImageUrl;
  final int targetSets;
  final int targetReps;
  final int restTime;
  final List<SetModel> sets;

  ExerciseSessionModel({
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseImageUrl,
    required this.targetSets,
    required this.targetReps,
    required this.restTime,
    List<SetModel>? sets,
  }) : sets =
           sets ??
           List.generate(targetSets, (index) => SetModel(setNumber: index + 1));

  bool get isComplete {
    return sets.where((s) => s.isComplete).length >= targetSets;
  }

  int get completedSets {
    return sets.where((s) => s.isComplete).length;
  }

  ExerciseSessionModel copyWith({
    int? exerciseId,
    String? exerciseName,
    String? exerciseImageUrl,
    int? targetSets,
    int? targetReps,
    int? restTime,
    List<SetModel>? sets,
  }) {
    return ExerciseSessionModel(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseImageUrl: exerciseImageUrl ?? this.exerciseImageUrl,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      restTime: restTime ?? this.restTime,
      sets: sets ?? this.sets,
    );
  }

  // Convert to API format for logging workout
  Map<String, dynamic> toApiDetail() {
    // Calculate average reps and weight from completed sets
    final completedSetsList = sets.where((s) => s.isComplete).toList();

    if (completedSetsList.isEmpty) {
      return {
        'exercise_id': exerciseId,
        'actual_sets': 0,
        'actual_reps': 0,
        'weight_lifted': 0,
      };
    }

    final avgReps =
        completedSetsList
            .map((s) => s.actualReps ?? 0)
            .reduce((a, b) => a + b) ~/
        completedSetsList.length;

    final avgWeight =
        completedSetsList
            .map((s) => s.weightLifted ?? 0)
            .reduce((a, b) => a + b) /
        completedSetsList.length;

    return {
      'exercise_id': exerciseId,
      'actual_sets': completedSetsList.length,
      'actual_reps': avgReps,
      'weight_lifted': avgWeight,
    };
  }
}
