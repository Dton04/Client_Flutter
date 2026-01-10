import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/plan_schedule_model.dart';
import '../../models/workout_session_model.dart';
import '../../models/exercise_session_model.dart';
import '../../models/set_model.dart';
import '../../services/tracking_service.dart';
import '../../config/api_config.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final PlanScheduleModel schedule;
  final int? planScheduleId;

  const WorkoutSessionScreen({
    super.key,
    required this.schedule,
    this.planScheduleId,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late WorkoutSessionModel _session;
  int _currentExerciseIndex = 0;
  final TextEditingController _notesController = TextEditingController();

  // Rest timer
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  bool _isResting = false;

  @override
  void initState() {
    super.initState();
    _session = WorkoutSessionModel(
      schedule: widget.schedule,
      planScheduleId: widget.planScheduleId,
    );
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  ExerciseSessionModel get _currentExercise {
    return _session.exercises[_currentExerciseIndex];
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = _currentExercise.restTime;
      _isResting = true;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_restSecondsRemaining > 0) {
          _restSecondsRemaining--;
        } else {
          _isResting = false;
          timer.cancel();
        }
      });
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restSecondsRemaining = 0;
    });
  }

  void _updateSet(int setIndex, {int? reps, double? weight, bool? complete}) {
    final updatedSets = List<SetModel>.from(_currentExercise.sets);
    updatedSets[setIndex] = updatedSets[setIndex].copyWith(
      actualReps: reps,
      weightLifted: weight,
      isComplete: complete,
    );

    final updatedExercise = _currentExercise.copyWith(sets: updatedSets);
    final updatedExercises = List<ExerciseSessionModel>.from(
      _session.exercises,
    );
    updatedExercises[_currentExerciseIndex] = updatedExercise;

    setState(() {
      _session = _session.copyWith(exercises: updatedExercises);
    });

    // Start rest timer if set is completed
    if (complete == true && !_isResting) {
      _startRestTimer();
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _skipRest();
      });
    }
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _session.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _skipRest();
      });
    }
  }

  void _skipExercise() {
    if (_currentExerciseIndex < _session.exercises.length - 1) {
      _nextExercise();
    }
  }

  Future<void> _completeWorkout() async {
    // Check if at least one exercise has been completed
    final hasCompletedExercises = _session.exercises.any(
      (e) => e.completedSets > 0,
    );

    if (!hasCompletedExercises) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete at least one exercise')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        title: const Text(
          'Complete Workout?',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duration: ${_session.durationMinutes} minutes',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Exercises: ${_session.completedExercises}/${_session.totalExercises}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Save workout
    try {
      _session.notes = _notesController.text;
      final apiRequest = _session.toApiRequest();

      await TrackingService.logWorkout(
        planScheduleId: apiRequest['plan_schedule_id'],
        performedAt: DateTime.parse(apiRequest['performed_at']),
        durationMinutes: apiRequest['duration_minutes'],
        notes: apiRequest['notes'],
        details: List<Map<String, dynamic>>.from(apiRequest['details']),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout logged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppConstants.cardColor,
            title: const Text(
              'Exit Workout?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Your progress will be lost if you exit now.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Exit', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            children: [
              Text(_session.schedule.title),
              Text(
                'Exercise ${_currentExerciseIndex + 1}/${_session.totalExercises}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.timer),
              onPressed: () {
                // Show duration
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppConstants.cardColor,
                    title: const Text(
                      'Workout Duration',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Text(
                      '${_session.durationMinutes} minutes',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentExerciseIndex + 1) / _session.totalExercises,
              backgroundColor: AppConstants.surfaceColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppConstants.primaryColor,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExerciseHeader(),
                    const SizedBox(height: 24),
                    _buildSetsSection(),
                    const SizedBox(height: 24),
                    if (_isResting) _buildRestTimer(),
                    const SizedBox(height: 24),
                    _buildNavigationButtons(),
                    const SizedBox(height: 24),
                    _buildNotesSection(),
                    const SizedBox(height: 24),
                    _buildCompleteButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseHeader() {
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
              if (_currentExercise.exerciseImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    ApiConfig.getFullImageUrl(
                      _currentExercise.exerciseImageUrl,
                    ),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: AppConstants.surfaceColor,
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.grey),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentExercise.exerciseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${_currentExercise.targetSets} sets × ${_currentExercise.targetReps} reps',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      'Rest: ${_currentExercise.restTime}s',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _currentExercise.completedSets / _currentExercise.targetSets,
            backgroundColor: AppConstants.surfaceColor,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 4),
          Text(
            'Completed: ${_currentExercise.completedSets}/${_currentExercise.targetSets} sets',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._currentExercise.sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          return _buildSetRow(index, set);
        }),
      ],
    );
  }

  Widget _buildSetRow(int index, SetModel set) {
    final repsController = TextEditingController(
      text: set.actualReps?.toString() ?? '',
    );
    final weightController = TextEditingController(
      text: set.weightLifted?.toString() ?? '',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: set.isComplete
            ? Colors.green.withOpacity(0.1)
            : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: set.isComplete ? Colors.green : AppConstants.borderColor,
        ),
      ),
      child: Row(
        children: [
          // Set number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: set.isComplete ? Colors.green : AppConstants.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: set.isComplete ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Reps input
          Expanded(
            child: TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Reps',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
                isDense: true,
              ),
              onChanged: (value) {
                _updateSet(index, reps: int.tryParse(value));
              },
            ),
          ),
          const SizedBox(width: 12),

          // Weight input
          Expanded(
            child: TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
                isDense: true,
              ),
              onChanged: (value) {
                _updateSet(index, weight: double.tryParse(value));
              },
            ),
          ),
          const SizedBox(width: 12),

          // Complete checkbox
          Checkbox(
            value: set.isComplete,
            onChanged: (value) {
              if (value == true) {
                // Ensure reps and weight are filled
                if (set.actualReps == null || set.actualReps == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter reps')),
                  );
                  return;
                }
              }
              _updateSet(index, complete: value);
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildRestTimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.primaryColor),
      ),
      child: Column(
        children: [
          const Text(
            'Rest Time',
            style: TextStyle(
              color: AppConstants.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(_restSecondsRemaining),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _skipRest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Skip Rest'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _currentExerciseIndex > 0 ? _previousExercise : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.primaryColor,
              side: const BorderSide(color: AppConstants.primaryColor),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _skipExercise,
            child: const Text('Skip'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey,
              side: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _currentExerciseIndex < _session.exercises.length - 1
                ? _nextExercise
                : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'How did you feel? Any observations?',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _completeWorkout,
        icon: const Icon(Icons.check_circle),
        label: const Text('Complete Workout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
