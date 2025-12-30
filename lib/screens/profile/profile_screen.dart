import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_profile_model.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/metric_card.dart';
import 'edit_profile_screen.dart';
import 'body_metrics_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          TextButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProfileScreen(userProfile: _userProfile!),
                ),
              );
              if (result == true) {
                _loadUserProfile();
              }
            },
            child: const Text(
              'Sửa',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontSize: AppConstants.fontSizeLarge,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
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
                  // Profile Header
                  _buildProfileHeader(),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Edit Profile Button
                  _buildEditProfileButton(),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Body Metrics
                  _buildBodyMetrics(),

                  const SizedBox(height: 12),

                  // Update Metrics Button
                  _buildUpdateMetricsButton(),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Fitness Goal
                  _buildFitnessGoal(),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Health Metrics
                  _buildHealthMetrics(),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Training Settings
                  _buildTrainingSettings(),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Logout Button
                  _buildLogoutButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Avatar with camera icon
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
                backgroundImage: _userProfile?.avatarUrl != null
                    ? NetworkImage(_userProfile!.avatarUrl!)
                    : null,
                child: _userProfile?.avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 50,
                        color: AppConstants.primaryColor,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppConstants.backgroundColor,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            _userProfile?.fullName ?? 'Người dùng',
            style: const TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // Membership badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  size: 16,
                  color: AppConstants.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Thành viên Pro',
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontSize: AppConstants.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Join date
          Text(
            _userProfile?.joinedAt != null
                ? 'Tham gia từ tháng ${DateFormat('M, yyyy').format(_userProfile!.joinedAt!)}'
                : 'Tham gia từ tháng 8, 2023',
            style: const TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: AppConstants.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () async {
          if (_userProfile != null) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EditProfileScreen(userProfile: _userProfile!),
              ),
            );
            if (result == true) {
              _loadUserProfile();
            }
          }
        },
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Chỉnh sửa hồ sơ'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: const BorderSide(color: AppConstants.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyMetrics() {
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            icon: Icons.monitor_weight_outlined,
            iconColor: Colors.blue,
            label: 'Cân nặng',
            value: _userProfile?.weight?.toStringAsFixed(0) ?? '75',
            unit: 'kg',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            icon: Icons.height_outlined,
            iconColor: Colors.green,
            label: 'Chiều cao',
            value: _userProfile?.height?.toStringAsFixed(0) ?? '180',
            unit: 'cm',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            icon: Icons.cake_outlined,
            iconColor: Colors.orange,
            label: 'Tuổi',
            value: _userProfile?.age?.toString() ?? '24',
            unit: '',
          ),
        ),
      ],
    );
  }

  Widget _buildFitnessGoal() {
    final goal = _userProfile?.fitnessGoal ?? 'Tăng cơ (Hypertrophy)';
    final targetWeight = _userProfile?.weight != null
        ? (_userProfile!.weight! + 5).toStringAsFixed(0)
        : '80';
    final currentWeight = _userProfile?.weight?.toStringAsFixed(0) ?? '70';
    final progress = _userProfile?.weight != null
        ? ((_userProfile!.weight! - 70) / 10).clamp(0.0, 1.0)
        : 0.75;

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
                'Mục tiêu hiện tại',
                style: TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ĐANG THỰC HIỆN',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal,
                      style: const TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mục tiêu: $targetWeight kg • Cần tăng thêm 5 kg',
                      style: const TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: AppConstants.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: AppConstants.textSecondaryColor,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bắt đầu: $currentWeight kg',
                style: const TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: AppConstants.fontSizeSmall,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppConstants.primaryColor,
                  fontSize: AppConstants.fontSizeSmall,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppConstants.borderColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppConstants.primaryColor,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chỉ số cơ thể',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        _buildHealthMetricItem(
          icon: Icons.monitor_heart_outlined,
          iconColor: Colors.green,
          label: 'BMI',
          value: _userProfile?.bmi?.toStringAsFixed(1) ?? '23.1',
          subtitle: 'Bình thường',
        ),

        const SizedBox(height: 12),

        _buildHealthMetricItem(
          icon: Icons.water_drop_outlined,
          iconColor: Colors.orange,
          label: 'Tỷ lệ mỡ',
          value:
              '${_userProfile?.bodyFatPercentage?.toStringAsFixed(0) ?? '15'}%',
          subtitle: 'Cân đối: cơ thể 2 ngày trước',
        ),
      ],
    );
  }

  Widget _buildHealthMetricItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppConstants.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cài đặt tập luyện',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        _buildSettingItem(
          icon: Icons.calendar_today_outlined,
          label: 'Tần suất tập luyện',
          value: '5 ngày / tuần',
        ),

        const SizedBox(height: 12),

        _buildSettingItem(
          icon: Icons.restaurant_outlined,
          label: 'Chế độ ăn',
          value: 'High Protein',
        ),

        const SizedBox(height: 12),

        _buildSettingItem(
          icon: Icons.straighten_outlined,
          label: 'Đơn vị đo',
          value: 'Metric (Kg, cm)',
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppConstants.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.textSecondaryColor, size: 20),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppConstants.textPrimaryColor,
                fontSize: AppConstants.fontSizeMedium,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: AppConstants.fontSizeMedium,
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.chevron_right,
            color: AppConstants.textSecondaryColor,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateMetricsButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BodyMetricsScreen()),
          );
          if (result == true) {
            _loadUserProfile();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Cập nhật chỉ số cơ thể'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppConstants.cardColor,
              title: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: AppConstants.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Bạn có chắc chắn muốn đăng xuất?',
                style: TextStyle(color: AppConstants.textSecondaryColor),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: AppConstants.textSecondaryColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Close dialog
                    Navigator.pop(context);

                    // Logout
                    await AuthService.logout();

                    // Navigate to login screen and clear navigation stack
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.errorColor,
                  ),
                  child: const Text(
                    'Đăng xuất',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout),
        label: const Text('Đăng xuất'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.errorColor,
          side: const BorderSide(color: AppConstants.errorColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
        ),
      ),
    );
  }
}
