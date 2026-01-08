import 'package:flutter/material.dart';
import '../../models/user_profile_model.dart';
import '../../services/profile_service.dart';
import '../../utils/constants.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/stat_card.dart';
import '../profile/profile_screen.dart';
import '../exercise/exercise_list_screen.dart';
import '../plan/plan_list_screen.dart';
import '../plan/create_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  UserProfileModel? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
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
      body: SafeArea(
        child: _buildBody(),
      ),
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
            child: CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
          )
        : SingleChildScrollView(
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
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: Colors.orange,
            label: 'Calories',
            value: '450',
            unit: '/ 800 kcal',
            progress: 0.56,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.timer_rounded,
            iconColor: Colors.blue,
            label: 'Duration',
            value: '45',
            unit: '/ 60 min',
            progress: 0.75,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.directions_run_rounded,
            iconColor: Colors.green,
            label: 'Distance',
            value: '5,2',
            unit: '/ 10k m',
            progress: 0.52,
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
                      child: const Text(
                        'STRENGTH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Title
                    const Text(
                      'Leg Day Crush',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Description
                    const Text(
                      'Build power and endurance',
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: AppConstants.fontSizeMedium,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stats
                    Row(
                      children: [
                        _buildWorkoutStat(Icons.timer_rounded, '45 min'),
                        const SizedBox(width: 16),
                        _buildWorkoutStat(Icons.fitness_center, '6 Exercises'),
                        const SizedBox(width: 16),
                        _buildWorkoutStat(
                          Icons.local_fire_department_rounded,
                          '420 Kcal',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Start button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Start workout
                        },
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
                '75%',
                style: TextStyle(
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
              value: 0.75,
              backgroundColor: AppConstants.borderColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppConstants.primaryColor,
              ),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            '3 of 4 workouts completed this week',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: AppConstants.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Activity',
              style: TextStyle(
                color: AppConstants.textPrimaryColor,
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: AppConstants.textSecondaryColor,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: AppConstants.textSecondaryColor,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        const Text(
          '4 Workouts',
          style: TextStyle(
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
              _buildBar('MON', 0.0),
              _buildBar('TUE', 0.6),
              _buildBar('WED', 0.0),
              _buildBar('THU', 0.9),
              _buildBar('FRI', 0.0),
              _buildBar('SAT', 0.7),
              _buildBar('SUN', 0.0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar(String day, double value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 100 * value,
          decoration: BoxDecoration(
            color: value > 0
                ? AppConstants.primaryColor
                : AppConstants.borderColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
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
}
