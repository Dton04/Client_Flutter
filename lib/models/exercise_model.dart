class ExerciseMediaModel {
  final int mediaId;
  final int exerciseId;
  final String url;
  final String mediaType; // 'IMAGE' or 'VIDEO'

  ExerciseMediaModel({
    required this.mediaId,
    required this.exerciseId,
    required this.url,
    required this.mediaType,
  });

  factory ExerciseMediaModel.fromJson(Map<String, dynamic> json) {
    return ExerciseMediaModel(
      mediaId: json['media_id'] is int ? json['media_id'] : int.tryParse(json['media_id']?.toString() ?? '0') ?? 0,
      exerciseId: json['exercise_id'] is int ? json['exercise_id'] : int.tryParse(json['exercise_id']?.toString() ?? '0') ?? 0,
      url: json['url']?.toString() ?? '',
      mediaType: (json['media_type']?.toString() ?? 'IMAGE').toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media_id': mediaId,
      'exercise_id': exerciseId,
      'url': url,
      'media_type': mediaType,
    };
  }
}

class ExerciseModel {
  final int exerciseId;
  final int muscleGroupId;
  final String name;
  final String? description;
  final String difficultyLevel;
  final int caloriesBurnEstimate;
  final List<ExerciseMediaModel> media;
  final String? thumbnail; // For list view convenience

  ExerciseModel({
    required this.exerciseId,
    required this.muscleGroupId,
    required this.name,
    this.description,
    required this.difficultyLevel,
    required this.caloriesBurnEstimate,
    this.media = const [],
    this.thumbnail,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    var mediaList = <ExerciseMediaModel>[];
    
    // Kiểm tra media có thể là List hoặc Map (Object đơn)
    if (json['media'] != null) {
      if (json['media'] is List) {
        mediaList = (json['media'] as List)
            .map((e) => ExerciseMediaModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (json['media'] is Map) {
        // Xử lý trường hợp API trả về media là một object duy nhất
        mediaList.add(ExerciseMediaModel.fromJson(json['media'] as Map<String, dynamic>));
      }
    }

    // Nếu mediaList trống, thử tìm trong 'exercise_media' (tên bảng trong DB)
    if (mediaList.isEmpty && json['exercise_media'] != null) {
       if (json['exercise_media'] is List) {
        mediaList = (json['exercise_media'] as List)
            .map((e) => ExerciseMediaModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (json['exercise_media'] is Map) {
        mediaList.add(ExerciseMediaModel.fromJson(json['exercise_media'] as Map<String, dynamic>));
      }
    }

    return ExerciseModel(
      exerciseId: json['exercise_id'] is int ? json['exercise_id'] : int.tryParse(json['exercise_id']?.toString() ?? '0') ?? 0,
      muscleGroupId: json['muscle_group_id'] is int ? json['muscle_group_id'] : int.tryParse(json['muscle_group_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Unknown Exercise',
      description: json['description']?.toString(),
      difficultyLevel: json['difficulty_level']?.toString() ?? 'Medium',
      caloriesBurnEstimate: json['calories_burn_estimate'] != null 
          ? (json['calories_burn_estimate'] is int 
              ? json['calories_burn_estimate'] 
              : int.tryParse(json['calories_burn_estimate'].toString()) ?? 0)
          : 0,
      media: mediaList,
      // Check multiple possible keys for thumbnail to handle inconsistent API responses
    // Also check snake_case and camelCase variations if needed
    thumbnail: json['thumbnail_url']?.toString() ?? 
               json['thumbnail']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'muscle_group_id': muscleGroupId,
      'name': name,
      'description': description,
      'difficulty_level': difficultyLevel,
      'calories_burn_estimate': caloriesBurnEstimate,
      'media': media.map((e) => e.toJson()).toList(),
      'thumbnail_url': thumbnail,
    };
  }

  ExerciseModel copyWith({
    int? exerciseId,
    int? muscleGroupId,
    String? name,
    String? description,
    String? difficultyLevel,
    int? caloriesBurnEstimate,
    List<ExerciseMediaModel>? media,
    String? thumbnail,
  }) {
    return ExerciseModel(
      exerciseId: exerciseId ?? this.exerciseId,
      muscleGroupId: muscleGroupId ?? this.muscleGroupId,
      name: name ?? this.name,
      description: description ?? this.description,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      caloriesBurnEstimate: caloriesBurnEstimate ?? this.caloriesBurnEstimate,
      media: media ?? this.media,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}