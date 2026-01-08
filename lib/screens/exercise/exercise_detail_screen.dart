import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Cần import package này
import '../../models/exercise_model.dart';
import '../../config/api_config.dart';
import '../../services/exercise_service.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final int exerciseId;
  final String exerciseName;

  const ExerciseDetailScreen({
    Key? key,
    required this.exerciseId,
    required this.exerciseName,
  }) : super(key: key);

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    try {
      final exercise = await ExerciseService.getExerciseDetail(widget.exerciseId);
      
      String muscleGroupName = 'Nhóm cơ khác';
      try {
        final groups = await ExerciseService.getMuscleGroups();
        final group = groups.firstWhere(
          (g) {
            final id = g['group_id'] ?? g['id'] ?? g['muscle_group_id'];
            return id == exercise.muscleGroupId;
          },
          orElse: () => null,
        );
        if (group != null) {
          muscleGroupName = group['group_name'] ?? group['name'] ?? 'Nhóm cơ khác';
        }
      } catch (e) {
        print('Error loading muscle group name: $e');
      }

      return {
        'exercise': exercise,
        'muscleGroupName': muscleGroupName,
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1F26), // Màu nền tối
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Không tìm thấy bài tập', style: const TextStyle(color: Colors.white)));
          }

          final exercise = snapshot.data!['exercise'] as ExerciseModel;
          final muscleGroupName = snapshot.data!['muscleGroupName'] as String;
          
          return _buildContent(exercise, muscleGroupName);
        },
      ),
   
      
    );
  }

  Widget _buildContent(ExerciseModel exercise, String muscleGroupName) {
    // === 1. LOGIC TÌM VIDEO & ẢNH (Fix logic cũ) ===
    
    // Hàm check đuôi file
    bool isVideoUrl(String url) {
      final u = url.toLowerCase();
      return u.endsWith('.mp4') || u.endsWith('.mov') || u.endsWith('.avi');
    }

    // A. Tìm Video: Ưu tiên loại 'VIDEO', nếu không có thì tìm link đuôi .mp4
    var videoMedia = exercise.media.firstWhere(
      (m) => m.mediaType == 'VIDEO',
      orElse: () => ExerciseMediaModel(mediaId: 0, exerciseId: 0, url: '', mediaType: ''),
    );

    if (videoMedia.url.isEmpty) {
      videoMedia = exercise.media.firstWhere(
        (m) => isVideoUrl(m.url),
        orElse: () => ExerciseMediaModel(mediaId: 0, exerciseId: 0, url: '', mediaType: ''),
      );
    }

    // B. Tìm Ảnh: Ưu tiên loại 'IMAGE', nếu không có thì tìm cái nào KHÔNG phải video
    var imageMedia = exercise.media.firstWhere(
      (m) => m.mediaType == 'IMAGE',
      orElse: () => ExerciseMediaModel(mediaId: 0, exerciseId: 0, url: '', mediaType: ''),
    );

    if (imageMedia.url.isEmpty) {
      imageMedia = exercise.media.firstWhere(
        (m) => !isVideoUrl(m.url) && m.mediaType != 'VIDEO',
        orElse: () => ExerciseMediaModel(mediaId: 0, exerciseId: 0, url: '', mediaType: ''),
      );
    }

    // C. Xác định URL ảnh hiển thị (cho Header & Thumbnail Video)
    final displayImageUrl = imageMedia.url.isNotEmpty 
        ? imageMedia.url 
        : (exercise.thumbnail ?? '');

    final hasVideo = videoMedia.url.isNotEmpty;

    // === 2. GIAO DIỆN ===
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Image ---
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (displayImageUrl.isNotEmpty)
                  Image.network(
                    ApiConfig.getFullImageUrl(displayImageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
                  )
                else
                  Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.fitness_center, color: Colors.white24, size: 64),
                    ),
                  ),
                
                // Dark gradient overlay (Lớp phủ tối dần xuống dưới)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        const Color(0xFF1C1F26),
                      ],
                    ),
                  ),
                ),

                // AppBar Actions (Nút Back & Favorite)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.red),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên bài tập
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Nhóm cơ & Độ khó
                Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      '$muscleGroupName • ${exercise.difficultyLevel}',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Thẻ thông số (Calories & Difficulty)
                Row(
                  children: [
                    Expanded(child: _buildStatCard(Icons.local_fire_department, '${exercise.caloriesBurnEstimate}', 'KCAL', Colors.orange)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(Icons.bar_chart, _getDifficultyText(exercise.difficultyLevel), 'ĐỘ KHÓ', Colors.red)),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Hướng dẫn ---
                const Text(
                  'Hướng dẫn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                _buildInstructions(exercise.description ?? 'Chưa có hướng dẫn chi tiết.'),
                
                const SizedBox(height: 32),
                
                // --- Video Player Section ---
                const Text(
                  'Video hướng dẫn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                if (hasVideo)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black, // Luôn có nền đen
                      borderRadius: BorderRadius.circular(16),
                      // Chỉ load ảnh nền nếu có URL ảnh, còn không thì để nền đen
                      image: displayImageUrl.isNotEmpty 
                          ? DecorationImage(
                              image: NetworkImage(ApiConfig.getFullImageUrl(displayImageUrl)),
                              fit: BoxFit.cover,
                              opacity: 0.5, // Làm tối ảnh để nút play nổi hơn
                            )
                          : null,
                    ),
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.play_circle_fill, size: 64, color: Colors.blue),
                        onPressed: () async {
                          try {
                            final Uri url = Uri.parse(videoMedia.url);
                            // Mở video bằng ứng dụng ngoài (Youtube, Browser, Player)
                            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không thể mở video này')),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi khi mở video: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  )
                else
                  // Giao diện khi KHÔNG có video
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C303A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[800]!),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.videocam_off, size: 48, color: Colors.grey[600]),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có video hướng dẫn',
                          style: TextStyle(color: Colors.grey[400], fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 80), // Khoảng trống dưới cùng
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C303A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(String description) {
    // Tách dòng để tạo danh sách các bước
    final steps = description.split('\n').where((s) => s.trim().isNotEmpty).toList();

    if (steps.isEmpty) {
      return Text(
        description,
        style: TextStyle(color: Colors.grey[400], height: 1.5),
      );
    }

    return Column(
      children: List.generate(steps.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  steps[index],
                  style: TextStyle(color: Colors.grey[400], height: 1.5),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _getDifficultyText(String level) {
    switch (level.toUpperCase()) {
      case 'EASY': return 'Dễ';
      case 'MEDIUM': return 'Vừa';
      case 'HARD': return 'Khó';
      default: return level;
    }
  }
}