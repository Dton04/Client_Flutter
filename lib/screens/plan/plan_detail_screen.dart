import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../config/api_config.dart';
import '../../services/workout_plan_service.dart';
import '../../models/workout_plan_model.dart';
import '../../models/plan_schedule_model.dart';
import '../../models/plan_exercise_model.dart';
import '../exercise/exercise_detail_screen.dart';
import '../workout/workout_session_screen.dart';

class PlanDetailScreen extends StatefulWidget {
  final int planId;
  final String planName;

  const PlanDetailScreen({
    super.key,
    required this.planId,
    required this.planName,
  });

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  bool _isLoading = true;
  WorkoutPlanModel? _plan;

  @override
  void initState() {
    super.initState();
    _loadPlanDetail();
  }

  Future<void> _loadPlanDetail() async {
    try {
      final plan = await WorkoutPlanService.getPlanDetail(widget.planId);
      setState(() {
        _plan = plan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.planName),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plan == null
          ? const Center(
              child: Text(
                'Plan not found',
                style: TextStyle(color: Colors.white),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Header Info
                  _buildPlanHeader(),
                  const SizedBox(height: 24),

                  // Schedules
                  const Text(
                    'Lịch tập luyện',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_plan!.schedules == null || _plan!.schedules!.isEmpty)
                    const Center(
                      child: Text(
                        'Chưa có lịch tập nào',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ..._plan!.schedules!.map(
                      (schedule) => _buildScheduleCard(schedule),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlanHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${_formatDate(_plan!.startDate)} - ${_formatDate(_plan!.endDate)}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          if (_plan!.description != null && _plan!.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _plan!.description!,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCard(PlanScheduleModel schedule) {
    final isToday = schedule.dayOfWeek.toUpperCase() == _getCurrentDay();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isToday ? Border.all(color: Colors.green, width: 2) : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isToday, // Auto expand today
          title: Row(
            children: [
              Text(
                schedule.dayOfWeek,
                style: TextStyle(
                  color: isToday ? Colors.green : AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            schedule.title,
            style: const TextStyle(color: Colors.white70),
          ),
          children: [
            if (schedule.exercises.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Ngày nghỉ (Rest Day)',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: schedule.exercises
                          .map((ex) => _buildExerciseItem(ex))
                          .toList(),
                    ),
                  ),
                  // Start Workout button for today
                  if (isToday && schedule.exercises.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _startWorkout(schedule),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Workout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(PlanExerciseModel exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseDetailScreen(
                  exerciseId: exercise.exerciseId,
                  exerciseName: exercise.exerciseName ?? 'Chi tiết bài tập',
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.exerciseName ?? 'Unknown Exercise',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTag('${exercise.targetSets} sets'),
                          const SizedBox(width: 8),
                          _buildTag('${exercise.targetReps} reps'),
                          const SizedBox(width: 8),
                          _buildTag('${exercise.targetRestTime}s rest'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppConstants.primaryColor, fontSize: 10),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _startWorkout(PlanScheduleModel schedule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSessionScreen(
          schedule: schedule,
          planScheduleId: schedule.scheduleId,
        ),
      ),
    ).then((result) {
      // Refresh if workout was completed
      if (result == true) {
        _loadPlanDetail();
      }
    });
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    const days = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    return days[now.weekday - 1];
  }
}
