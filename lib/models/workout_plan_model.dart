import 'plan_schedule_model.dart';

class WorkoutPlanModel {
  final int planId;
  final String planName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final String? status;
  final List<PlanScheduleModel>? schedules;

  WorkoutPlanModel({
    required this.planId,
    required this.planName,
    this.startDate,
    this.endDate,
    this.description,
    this.status,
    this.schedules,
  });

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) {
    var schedulesList = <PlanScheduleModel>[];
    if (json['schedules'] != null) {
      schedulesList = (json['schedules'] as List)
          .map((e) => PlanScheduleModel.fromJson(e))
          .toList();
    }

    return WorkoutPlanModel(
      planId: json['plan_id'] as int,
      planName: json['plan_name'] as String,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      description: json['description'] as String?,
      status: json['status'] as String?,
      schedules: json['schedules'] != null ? schedulesList : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'plan_name': planName,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'description': description,
      'status': status,
      'schedules': schedules?.map((e) => e.toJson()).toList(),
    };
  }

  WorkoutPlanModel copyWith({
    int? planId,
    String? planName,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? status,
    List<PlanScheduleModel>? schedules,
  }) {
    return WorkoutPlanModel(
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      status: status ?? this.status,
      schedules: schedules ?? this.schedules,
    );
  }
}
