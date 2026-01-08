import '../config/api_config.dart';
import '../models/workout_plan_model.dart';
import '../models/plan_schedule_model.dart';
import '../models/plan_exercise_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class WorkoutPlanService {
  // 21. Create Plan
  static Future<WorkoutPlanModel> createPlan({
    required String planName,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await ApiService.post(
        url: ApiConfig.plansUrl,
        body: {
          'plan_name': planName,
          'start_date': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD
          'end_date': endDate.toIso8601String().split('T')[0],
          'description': description,
        },
        headers: ApiConfig.headersWithToken(token),
      );

      // response is Map<String, dynamic> like { "plan_id": 10, "message": "Plan created" }
      final data = response as Map<String, dynamic>;
      
      return WorkoutPlanModel(
        planId: data['plan_id'],
        planName: planName,
        startDate: startDate,
        endDate: endDate,
        description: description,
        status: 'Active',
      );
    } catch (e) {
      rethrow;
    }
  }

  // 22. Get My Plans
  static Future<List<WorkoutPlanModel>> getMyPlans() async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await ApiService.get(
        url: ApiConfig.plansUrl,
        headers: ApiConfig.headersWithToken(token),
      );

      if (response is List) {
        return response
            .map((e) => WorkoutPlanModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic> && response['data'] != null) {
        return (response['data'] as List)
            .map((e) => WorkoutPlanModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }
  
  // 23. Get Plan Detail
  static Future<WorkoutPlanModel> getPlanDetail(int planId) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await ApiService.get(
        url: '${ApiConfig.plansUrl}/$planId',
        headers: ApiConfig.headersWithToken(token),
      );

      return WorkoutPlanModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // 24. Create/Update Schedule
  static Future<PlanScheduleModel> createSchedule({
    required int planId,
    required String dayOfWeek,
    required String title,
  }) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await ApiService.post(
        url: ApiConfig.planSchedulesUrl(planId),
        body: {
          'day_of_week': dayOfWeek,
          'title': title,
        },
        headers: ApiConfig.headersWithToken(token),
      );

      final data = response as Map<String, dynamic>;

      return PlanScheduleModel(
        scheduleId: data['schedule_id'],
        dayOfWeek: dayOfWeek,
        title: title,
      );
    } catch (e) {
      rethrow;
    }
  }

  // 25. Add Exercise to Schedule
  static Future<PlanExerciseModel> addExerciseToSchedule({
    required int scheduleId,
    required int exerciseId,
    required int targetSets,
    required int targetReps,
    required int targetRestTime,
  }) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await ApiService.post(
        url: ApiConfig.scheduleExercisesUrl(scheduleId),
        body: {
          'exercise_id': exerciseId,
          'target_sets': targetSets,
          'target_reps': targetReps,
          'target_rest_time': targetRestTime,
        },
        headers: ApiConfig.headersWithToken(token),
      );

      final data = response as Map<String, dynamic>;

      return PlanExerciseModel(
        planExerciseId: data['plan_exercise_id'],
        exerciseId: exerciseId,
        targetSets: targetSets,
        targetReps: targetReps,
        targetRestTime: targetRestTime,
      );
    } catch (e) {
      rethrow;
    }
  }

  // 26. Update Plan Exercise
  static Future<void> updatePlanExercise({
    required int planExerciseId,
    int? targetSets,
    int? targetReps,
    int? targetRestTime,
  }) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }
      
      final body = <String, dynamic>{};
      if (targetSets != null) body['target_sets'] = targetSets;
      if (targetReps != null) body['target_reps'] = targetReps;
      if (targetRestTime != null) body['target_rest_time'] = targetRestTime;

      await ApiService.put(
        url: ApiConfig.planExercisesUrl(planExerciseId),
        body: body,
        headers: ApiConfig.headersWithToken(token),
      );
    } catch (e) {
      rethrow;
    }
  }

  // 27. Delete Plan Exercise
  static Future<void> deletePlanExercise(int planExerciseId) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      await ApiService.delete(
        url: ApiConfig.planExercisesUrl(planExerciseId),
        headers: ApiConfig.headersWithToken(token),
      );
    } catch (e) {
      rethrow;
    }
  }

  // 29. Delete Plan
  static Future<void> deletePlan(int planId) async {
    try {
      final token = StorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      await ApiService.delete(
        url: '${ApiConfig.plansUrl}/$planId',
        headers: ApiConfig.headersWithToken(token),
      );
    } catch (e) {
      rethrow;
    }
  }
}
