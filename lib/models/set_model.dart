class SetModel {
  final int setNumber;
  int? actualReps;
  double? weightLifted;
  bool isComplete;

  SetModel({
    required this.setNumber,
    this.actualReps,
    this.weightLifted,
    this.isComplete = false,
  });

  SetModel copyWith({
    int? setNumber,
    int? actualReps,
    double? weightLifted,
    bool? isComplete,
  }) {
    return SetModel(
      setNumber: setNumber ?? this.setNumber,
      actualReps: actualReps ?? this.actualReps,
      weightLifted: weightLifted ?? this.weightLifted,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  Map<String, dynamic> toJson() {
    return {'actual_reps': actualReps, 'weight_lifted': weightLifted};
  }
}
