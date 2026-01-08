import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/workout_plan_service.dart';
import '../../models/plan_schedule_model.dart';

import '../exercise/exercise_list_screen.dart';
import '../../models/exercise_model.dart';
import '../../models/plan_exercise_model.dart';
import '../../config/api_config.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  
  // Local state for schedule (not saved to DB yet)
  // We just visualize the structure: Monday, Tuesday...
  final List<String> _daysOfWeek = [
    'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'
  ];
  
  // Map day -> PlanScheduleModel (dummy)
  final Map<String, PlanScheduleModel> _schedules = {};

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('New Plan'),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        leadingWidth: 80,
        actions: [
          TextButton(
            onPressed: _savePlan,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Name
              const Text('Plan Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'e.g., Summer Shred',
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(Icons.edit, color: Colors.grey, size: 20),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 24),

              // Description
              const Text('Description', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "What's the goal of this plan? e.g. Build muscle, lose fat...",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),

              // Duration
              const Text('Duration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker('START DATE', _startDate, (date) {
                      setState(() => _startDate = date);
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker('END DATE', _endDate, (date) {
                      setState(() => _endDate = date);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Weekly Schedule Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Weekly Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _schedules.clear();
                      });
                    },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Schedule List
              ..._daysOfWeek.map((day) => _buildDayCard(day)),

              const SizedBox(height: 32),
              
              // Delete Button (Only if editing, but this is Create screen so maybe redundant)
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete, color: AppConstants.errorColor),
                  label: const Text('Delete Plan', style: TextStyle(color: AppConstants.errorColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onSelect(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConstants.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppConstants.primaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(String day) {
    final shortDay = day.substring(0, 3); // MON, TUE...
    final schedule = _schedules[day];
    final hasSchedule = schedule != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: hasSchedule 
            ? Border.all(color: AppConstants.primaryColor.withOpacity(0.3))
            : Border.all(style: BorderStyle.none),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: hasSchedule ? AppConstants.primaryColor.withOpacity(0.2) : AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            shortDay,
            style: TextStyle(
              color: hasSchedule ? AppConstants.primaryColor : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          hasSchedule ? schedule.title : 'Rest Day',
          style: TextStyle(
            color: hasSchedule ? Colors.white : Colors.grey,
            fontWeight: hasSchedule ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: hasSchedule
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${schedule.exercises.length} Exercises', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  if (schedule.exercises.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...schedule.exercises.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          if (e.exerciseImageUrl != null && e.exerciseImageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                ApiConfig.getFullImageUrl(e.exerciseImageUrl),
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, size: 20, color: Colors.grey),
                              ),
                            )
                          else
                            const Icon(Icons.fitness_center, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.exerciseName ?? 'Exercise', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                Text('${e.targetSets} sets x ${e.targetReps} reps', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _schedules[day]!.exercises.remove(e);
                              });
                            },
                          ),
                        ],
                      ),
                    )),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 30,
                    child: OutlinedButton.icon(
                      onPressed: () => _addExerciseToDay(day),
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Add Exercise', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.primaryColor,
                        side: const BorderSide(color: AppConstants.primaryColor),
                      ),
                    ),
                  ),
                ],
              )
            : null,
        trailing: hasSchedule
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () => _openScheduleDialog(day),
              )
            : TextButton.icon(
                onPressed: () => _openScheduleDialog(day),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  backgroundColor: AppConstants.surfaceColor,
                  foregroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
        onTap: () => _openScheduleDialog(day),
      ),
    );
  }

  Future<void> _addExerciseToDay(String day) async {
    final selectedExercise = await Navigator.push<ExerciseModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseListScreen(isSelectionMode: true),
      ),
    );

    if (selectedExercise != null && mounted) {
      _showExerciseDetailsDialog(day, selectedExercise);
    }
  }

  void _showExerciseDetailsDialog(String day, ExerciseModel exercise) {
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '12');
    final restController = TextEditingController(text: '60');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        title: Text('Add ${exercise.name}', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNumberInput('Target Sets', setsController),
            const SizedBox(height: 12),
            _buildNumberInput('Target Reps', repsController),
            const SizedBox(height: 12),
            _buildNumberInput('Rest Time (sec)', restController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final sets = int.tryParse(setsController.text) ?? 3;
              final reps = int.tryParse(repsController.text) ?? 12;
              final rest = int.tryParse(restController.text) ?? 60;

              setState(() {
                final newExercise = PlanExerciseModel(
                  planExerciseId: 0, // Temp ID
                  exerciseId: exercise.exerciseId,
                  exerciseName: exercise.name,
                  exerciseImageUrl: exercise.thumbnail,
                  targetSets: sets,
                  targetReps: reps,
                  targetRestTime: rest,
                );
                
                // Ensure exercises list is modifiable
                var currentList = List<PlanExerciseModel>.from(_schedules[day]!.exercises);
                currentList.add(newExercise);
                
                _schedules[day] = _schedules[day]!.copyWith(exercises: currentList);
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppConstants.primaryColor)),
      ),
    );
  }

  void _openScheduleDialog(String day) {
    // Simple dialog to set title for now
    final titleController = TextEditingController(text: _schedules[day]?.title ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        title: Text('Schedule for $day', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: titleController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'e.g., Chest & Triceps'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _schedules[day] = PlanScheduleModel(
                    dayOfWeek: day,
                    title: titleController.text,
                    exercises: [], // Empty initially
                  );
                });
              } else {
                setState(() {
                  _schedules.remove(day);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      // 1. Create Plan
      final plan = await WorkoutPlanService.createPlan(
        planName: _nameController.text,
        startDate: _startDate,
        endDate: _endDate,
        description: _descController.text,
      );
      
      // 2. Create Schedules (if any)
            for (var day in _schedules.keys) {
              final schedule = _schedules[day]!;
              final createdSchedule = await WorkoutPlanService.createSchedule(
                planId: plan.planId,
                dayOfWeek: day,
                title: schedule.title,
              );

              // 3. Add Exercises to Schedule
              for (var exercise in schedule.exercises) {
                await WorkoutPlanService.addExerciseToSchedule(
                  scheduleId: createdSchedule.scheduleId!, // Now we have ID
                  exerciseId: exercise.exerciseId,
                  targetSets: exercise.targetSets,
                  targetReps: exercise.targetReps,
                  targetRestTime: exercise.targetRestTime,
                );
              }
            }
            
            if (mounted) {
        Navigator.pop(context, true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
