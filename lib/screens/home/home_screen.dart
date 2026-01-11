import 'package:flutter/material.dart';
import '../../models/user_profile_model.dart';
import '../../models/dashboard_stats_model.dart';
import '../../models/workout_history_model.dart';
import '../../models/workout_plan_model.dart';
import '../../models/plan_schedule_model.dart';
import '../../services/profile_service.dart';
import '../../services/tracking_service.dart';
import '../../services/workout_plan_service.dart';
import '../../utils/constants.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/stat_card.dart';
import '../profile/profile_screen.dart';
import '../exercise/exercise_list_screen.dart';
import '../plan/plan_list_screen.dart';
import '../plan/create_plan_screen.dart';
import '../workout/workout_session_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  UserProfileModel? _userProfile;
  DashboardStatsModel? _dashboardStats;
  List<WorkoutHistoryModel> _weeklyWorkouts = [];
  WorkoutPlanModel? _todayPlan;
  PlanScheduleModel? _todaySchedule;
  bool _isTodayWorkoutCompleted = false;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _todayWorkoutError;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadUserProfile(),
      _loadDashboardData(),
      _loadWeeklyActivity(),
      _loadTodayWorkout(),
    ]);
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadAllData();

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      final stats = await TrackingService.getDashboardStats();
      if (mounted) {
        setState(() {
          _dashboardStats = stats;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không thể tải thống kê: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _loadWeeklyActivity() async {
    try {
      final now = DateTime.now();
      final workouts = await TrackingService.getWorkoutHistory(
        month: now.month,
        year: now.year,
      );

      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final weeklyWorkouts = workouts.where((workout) {
        return workout.performedAt.isAfter(
              startOfWeek.subtract(const Duration(days: 1)),
            ) &&
            workout.performedAt.isBefore(
              endOfWeek.add(const Duration(days: 1)),
            );
      }).toList();

      if (mounted) {
        setState(() {
          _weeklyWorkouts = weeklyWorkouts;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weeklyWorkouts = [];
        });
      }
    }
  }

  Future<void> _loadTodayWorkout() async {
    try {
      final plans = await WorkoutPlanService.getMyPlans();

      if (plans.isEmpty) {
        if (mounted) {
          setState(() {
            _todayWorkoutError =
                'No active workout plan. Create one to get started!';
          });
        }
        return;
      }

      final plan = await WorkoutPlanService.getPlanDetail(plans.first.planId);

      final today = _getCurrentDay();
      final todaySchedule = plan.schedules?.firstWhere(
        (s) => s.dayOfWeek.toUpperCase() == today,
        orElse: () => throw Exception('No schedule'),
      );

      final todayDate = DateTime.now();
      final hasCompletedToday = _weeklyWorkouts.any((workout) {
        return workout.performedAt.year == todayDate.year &&
            workout.performedAt.month == todayDate.month &&
            workout.performedAt.day == todayDate.day;
      });

      if (mounted) {
        setState(() {
          _todayPlan = plan;
          _todaySchedule = todaySchedule;
          _isTodayWorkoutCompleted = hasCompletedToday;
          _todayWorkoutError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _todayWorkoutError = e.toString().contains('No schedule')
              ? 'Rest day! No workout scheduled for today.'
              : 'Unable to load today\'s workout';
        });
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await ProfileService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải thông tin: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _onNavTap(int index) {
    if (index == 2) {
      // Create Plan Button
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreatePlanScreen()),
      ).then((_) {
        // Refresh if needed
      });
    } else if (index == 4) {
      // Navigate to Profile screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      setState(() {
        _currentNavIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      resizeToAvoidBottomInset: false, // Prevent overflow when keyboard appears
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const ExerciseListScreen();
      case 3:
        return const PlanListScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: AppConstants.primaryColor),
          )
        : RefreshIndicator(
            onRefresh: _refreshData,
            color: AppConstants.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Stats Cards
                  _buildStatsCards(),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Today's Focus
                  _buildTodaysFocus(),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Weekly Goal
                  _buildWeeklyGoal(),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Activity
                  _buildActivity(),

                  const SizedBox(height: 80), // Space for bottom nav
                ],
              ),
            ),
          );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: AppConstants.primaryColor,
          backgroundImage: _userProfile?.avatarUrl != null
              ? NetworkImage(_userProfile!.avatarUrl!)
              : null,
          child: _userProfile?.avatarUrl == null
              ? Text(
                  _userProfile?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),

        const SizedBox(width: 12),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Morning,',
                style: TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: AppConstants.fontSizeMedium,
                ),
              ),
              Text(
                _userProfile?.fullName ?? 'User',
                style: const TextStyle(
                  color: AppConstants.textPrimaryColor,
                  fontSize: AppConstants.fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Notification icon
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppConstants.textPrimaryColor,
          ),
          onPressed: () {
            // TODO: Handle notifications
          },
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final totalWorkouts = _dashboardStats?.totalWorkouts ?? 0;
    final totalMinutes = _dashboardStats?.totalMinutes ?? 0;
    final currentStreak = _dashboardStats?.currentStreak ?? 0;

    // Calculate hours and minutes
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final durationText = hours > 0 ? '$hours' : '$minutes';
    final durationUnit = hours > 0 ? 'hrs' : 'min';

    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.fitness_center_rounded,
            iconColor: Colors.orange,
            label: 'Workouts',
            value: '$totalWorkouts',
            unit: 'total',
            progress: totalWorkouts > 0
                ? (totalWorkouts / 100).clamp(0.0, 1.0)
                : 0.0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.timer_rounded,
            iconColor: Colors.blue,
            label: 'Duration',
            value: durationText,
            unit: durationUnit,
            progress: totalMinutes > 0
                ? (totalMinutes / 1000).clamp(0.0, 1.0)
                : 0.0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: Colors.green,
            label: 'Streak',
            value: '$currentStreak',
            unit: 'days',
            progress: currentStreak > 0
                ? (currentStreak / 30).clamp(0.0, 1.0)
                : 0.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysFocus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TODAY'S FOCUS",
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 12),

        // Show error message if there's an error
        if (_todayWorkoutError != null)
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              border: Border.all(color: AppConstants.borderColor, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  _todayWorkoutError!.contains('Rest day')
                      ? Icons.spa_outlined
                      : Icons.fitness_center_outlined,
                  size: 48,
                  color: AppConstants.textSecondaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  _todayWorkoutError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: AppConstants.fontSizeMedium,
                  ),
                ),
                if (!_todayWorkoutError!.contains('Rest day')) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreatePlanScreen(),
                          ),
                        ).then((_) => _refreshData());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Create Plan'),
                    ),
                  ),
                ],
              ],
            ),
          )
        else if (_todaySchedule != null && _todayPlan != null)
          Container(
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              border: Border.all(color: AppConstants.borderColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workout Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.borderRadiusMedium),
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: AppConstants.surfaceColor,
                    child: const Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _todaySchedule!.dayOfWeek.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Title
                      Text(
                        _todaySchedule!.title,
                        style: const TextStyle(
                          color: AppConstants.textPrimaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Description
                      Text(
                        _todayPlan!.planName,
                        style: const TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: AppConstants.fontSizeMedium,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stats
                      Row(
                        children: [
                          _buildWorkoutStat(
                            Icons.fitness_center,
                            '${_todaySchedule!.exercises.length} Exercises',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Completion status or Start button
                      if (_isTodayWorkoutCompleted)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Completed Today!',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: AppConstants.fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _startTodayWorkout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Start Workout',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeLarge,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildWorkoutStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppConstants.primaryColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: AppConstants.fontSizeSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyGoal() {
    final weeklyWorkoutCount = _weeklyWorkouts.length;
    const weeklyGoal = 4; // Target: 4 workouts per week
    final progress = (weeklyWorkoutCount / weeklyGoal).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppConstants.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Goal',
                style: TextStyle(
                  color: AppConstants.textPrimaryColor,
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: AppConstants.primaryColor,
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppConstants.borderColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppConstants.primaryColor,
              ),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '$weeklyWorkoutCount of $weeklyGoal workouts completed this week',
            style: const TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: AppConstants.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivity() {
    // Count workouts by day of week (0 = Monday, 6 = Sunday)
    final workoutsByDay = List<int>.filled(7, 0);
    for (var workout in _weeklyWorkouts) {
      final dayIndex = workout.dayOfWeek;
      if (dayIndex >= 0 && dayIndex < 7) {
        workoutsByDay[dayIndex]++;
      }
    }

    // Find max for scaling
    final maxWorkouts = workoutsByDay.reduce((a, b) => a > b ? a : b);
    final totalWorkouts = _weeklyWorkouts.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          '$totalWorkouts Workout${totalWorkouts != 1 ? 's' : ''}',
          style: const TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // Bar chart
        Container(
          height: 150,
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppConstants.cardColor,
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
            border: Border.all(color: AppConstants.borderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar('MON', workoutsByDay[0], maxWorkouts),
              _buildBar('TUE', workoutsByDay[1], maxWorkouts),
              _buildBar('WED', workoutsByDay[2], maxWorkouts),
              _buildBar('THU', workoutsByDay[3], maxWorkouts),
              _buildBar('FRI', workoutsByDay[4], maxWorkouts),
              _buildBar('SAT', workoutsByDay[5], maxWorkouts),
              _buildBar('SUN', workoutsByDay[6], maxWorkouts),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar(String day, int workoutCount, int maxWorkouts) {
    // Calculate height as percentage of max (with minimum height for visibility)
    final double heightRatio = maxWorkouts > 0
        ? workoutCount / maxWorkouts
        : 0.0;
    final double barHeight = heightRatio > 0
        ? (100 * heightRatio).clamp(20.0, 100.0)
        : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Workout count label
        if (workoutCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '$workoutCount',
              style: const TextStyle(
                color: AppConstants.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          const SizedBox(height: 16),
        // Bar
        Container(
          width: 32,
          height: barHeight,
          decoration: BoxDecoration(
            color: workoutCount > 0
                ? AppConstants.primaryColor
                : AppConstants.borderColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        // Day label
        Text(
          day,
          style: const TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Future<void> _startTodayWorkout() async {
    // Check if we have today's schedule loaded
    if (_todaySchedule == null || _todayPlan == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _todayWorkoutError ?? 'No workout scheduled for today',
            ),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
      return;
    }

    // Navigate to workout session with the loaded schedule
    if (mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutSessionScreen(
            schedule: _todaySchedule!,
            planScheduleId: _todaySchedule!.scheduleId,
          ),
        ),
      );

      // Refresh data if workout was completed
      if (result == true && mounted) {
        _refreshData();
      }
    }
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
