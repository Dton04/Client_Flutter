import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../config/api_config.dart'; // Import ApiConfig
import '../../services/exercise_service.dart';
import '../../models/exercise_model.dart';
import '../../widgets/loading_overlay.dart';
import 'exercise_detail_screen.dart';

class ExerciseListScreen extends StatefulWidget {
  final bool isSelectionMode;

  const ExerciseListScreen({super.key, this.isSelectionMode = false});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  // State
  bool _isLoading = false;
  List<ExerciseModel> _exercises = [];
  
  // Filters
  final TextEditingController _searchController = TextEditingController();
  dynamic _selectedMuscleGroup; // Null = All (Changed to dynamic)
  String? _selectedDifficulty; // Null = All
  
  // Dynamic data for filters
  List<dynamic> _muscleGroups = [
    {'id': null, 'name': 'Tất cả'},
  ];

  final List<String?> _difficulties = [
    null,
    'EASY',
    'MEDIUM',
    'HARD',
  ];

  @override
  void initState() {
    super.initState();
    _loadMuscleGroups();
    _loadExercises();
  }

  Future<void> _loadMuscleGroups() async {
    try {
      final groups = await ExerciseService.getMuscleGroups();
      
      // Normalize data from API based on DB schema: group_id, group_name
      final normalizedGroups = groups.map((g) {
        return {
          'id': g['group_id'] ?? g['id'] ?? g['muscle_group_id'], // Prioritize group_id
          'name': g['group_name'] ?? g['name'] ?? 'Unknown', // Prioritize group_name
        };
      }).toList();

      final List<dynamic> newMuscleGroups = [{'id': null, 'name': 'Tất cả'}];
      newMuscleGroups.addAll(normalizedGroups);

      setState(() {
        _muscleGroups = newMuscleGroups;
      });
    } catch (e) {
      print('Error loading muscle groups: $e');
      // Fallback or keep "All" only
    }
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      final response = await ExerciseService.getExercises(
        muscleGroupId: _selectedMuscleGroup,
        difficulty: _selectedDifficulty,
        keyword: _searchController.text,
        limit: 50, // Get more for scroll
      );
      
      if (response['data'] != null) {
        setState(() {
          _exercises = (response['data'] as List)
              .map((e) => ExerciseModel.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getDifficultyLabel(String? diff) {
    if (diff == null) return 'Tất cả';
    switch (diff.toUpperCase()) { // Handle case-insensitive
      case 'EASY': return 'Dễ';
      case 'MEDIUM': return 'Trung bình';
      case 'HARD': return 'Khó';
      case 'BEGINNER': return 'Dễ'; // Fallback support
      case 'INTERMEDIATE': return 'Trung bình'; // Fallback support
      case 'ADVANCED': return 'Khó'; // Fallback support
      default: return diff;
    }
  }

  Color _getDifficultyColor(String diff) {
    switch (diff.toUpperCase()) {
      case 'EASY': return Colors.green;
      case 'MEDIUM': return Colors.orange;
      case 'HARD': return Colors.red;
      case 'BEGINNER': return Colors.green;
      case 'INTERMEDIATE': return Colors.orange;
      case 'ADVANCED': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header & Search
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Danh sách bài tập',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppConstants.fontSizeXXLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: _loadExercises,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar (if expanded or just use this as display)
                  // For now, let's keep it simple as per design
                ],
              ),
            ),

            // Muscle Group Filter
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                scrollDirection: Axis.horizontal,
                itemCount: _muscleGroups.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final group = _muscleGroups[index];
                  // Handle both "id" (from manual map) and likely "muscle_group_id" or "id" from API
                  final groupId = group['id'] ?? group['muscle_group_id']; 
                  final groupName = group['name'] ?? group['muscle_group_name'] ?? 'Unknown';
                  
                  final isSelected = _selectedMuscleGroup == groupId;
                  return ChoiceChip(
                    label: Text(groupName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedMuscleGroup = selected ? groupId : null;
                      });
                      _loadExercises();
                    },
                    backgroundColor: AppConstants.cardColor,
                    selectedColor: AppConstants.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Difficulty Filter
            SizedBox(
              height: 32,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                scrollDirection: Axis.horizontal,
                itemCount: _difficulties.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final diff = _difficulties[index];
                  final isSelected = _selectedDifficulty == diff;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDifficulty = isSelected ? null : diff;
                      });
                      _loadExercises();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppConstants.cardColor.withOpacity(0.8) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppConstants.primaryColor : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        _getDifficultyLabel(diff),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Exercise List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      itemCount: _exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _exercises[index];
                        return _buildExerciseCard(exercise);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise) {
    // Determine image URL: check thumbnail_url first, then look for IMAGE in media list
    // Priority: Media (IMAGE) > Thumbnail
    
    // Find media
    final imageMedia = exercise.media.firstWhere(
      (m) => m.mediaType == 'IMAGE',
      orElse: () => ExerciseMediaModel(mediaId: 0, exerciseId: 0, url: '', mediaType: ''),
    );

    final imageUrl = imageMedia.url.isNotEmpty ? imageMedia.url : (exercise.thumbnail ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
                onTap: () {
                  if (widget.isSelectionMode) {
                    Navigator.pop(context, exercise);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseDetailScreen(
                          exerciseId: exercise.exerciseId,
                          exerciseName: exercise.name,
                        ),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.black26,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            ApiConfig.getFullImageUrl(imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(Icons.fitness_center, color: Colors.grey),
                          )
                        : const Icon(Icons.fitness_center, color: Colors.grey, size: 32),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags Row
                      Row(
                        children: [
                          // Difficulty Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(exercise.difficultyLevel).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getDifficultyColor(exercise.difficultyLevel).withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              _getDifficultyLabel(exercise.difficultyLevel).toUpperCase(),
                              style: TextStyle(
                                color: _getDifficultyColor(exercise.difficultyLevel),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Action Button
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppConstants.surfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}