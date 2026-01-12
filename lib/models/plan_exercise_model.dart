class PlanExerciseModel {
  final int planExerciseId;
  final int exerciseId;
  final String? exerciseName; // From Join
  final String? exerciseImageUrl; // From Join
  final int targetSets;
  final int targetReps;
  final int targetRestTime; // In seconds

  PlanExerciseModel({
    required this.planExerciseId,
    required this.exerciseId,
    this.exerciseName,
    this.exerciseImageUrl,
    required this.targetSets,
    required this.targetReps,
    required this.targetRestTime,
  });

  factory PlanExerciseModel.fromJson(Map<String, dynamic> json) {
    return PlanExerciseModel(
      planExerciseId: json['plan_exercise_id'] is int ? json['plan_exercise_id'] : int.tryParse(json['plan_exercise_id']?.toString() ?? '0') ?? 0,
      exerciseId: json['exercise_id'] is int ? json['exercise_id'] : int.tryParse(json['exercise_id']?.toString() ?? '0') ?? 0,
      exerciseName: json['name']?.toString() ?? json['exercise_name']?.toString(), 
      exerciseImageUrl: json['url']?.toString(),
      targetSets: json['target_sets'] is int ? json['target_sets'] : int.tryParse(json['target_sets']?.toString() ?? '0') ?? 0,
      targetReps: json['target_reps'] is int ? json['target_reps'] : int.tryParse(json['target_reps']?.toString() ?? '0') ?? 0,
      targetRestTime: json['target_rest_time'] is int ? json['target_rest_time'] : int.tryParse(json['target_rest_time']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_exercise_id': planExerciseId,
      'exercise_id': exerciseId,
      'name': exerciseName,
      'image_url': exerciseImageUrl,
      'target_sets': targetSets,
      'target_reps': targetReps,
      'target_rest_time': targetRestTime,
    };
  }

  PlanExerciseModel copyWith({
    int? planExerciseId,
    int? exerciseId,
    String? exerciseName,
    String? exerciseImageUrl,
    int? targetSets,
    int? targetReps,
    int? targetRestTime,
  }) {
    return PlanExerciseModel(
      planExerciseId: planExerciseId ?? this.planExerciseId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseImageUrl: exerciseImageUrl ?? this.exerciseImageUrl,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetRestTime: targetRestTime ?? this.targetRestTime,
    );
  }
}
