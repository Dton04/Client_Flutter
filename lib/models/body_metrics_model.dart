class BodyMetricsModel {
  final int? metricId;
  final double weight;
  final double height;
  final double? bodyFatPercentage;
  final DateTime? recordedAt;

  BodyMetricsModel({
    this.metricId,
    required this.weight,
    required this.height,
    this.bodyFatPercentage,
    this.recordedAt,
  });

  factory BodyMetricsModel.fromJson(Map<String, dynamic> json) {
    return BodyMetricsModel(
      metricId: json['metric_id'] as int?,
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      bodyFatPercentage: json['body_fat_percentage'] != null
          ? (json['body_fat_percentage'] as num).toDouble()
          : null,
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (metricId != null) 'metric_id': metricId,
      'weight': weight,
      'height': height,
      if (bodyFatPercentage != null) 'body_fat_percentage': bodyFatPercentage,
      if (recordedAt != null) 'recorded_at': recordedAt!.toIso8601String(),
    };
  }

  // Calculate BMI
  double get bmi {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Thiếu cân';
    if (bmiValue < 25) return 'Bình thường';
    if (bmiValue < 30) return 'Thừa cân';
    return 'Béo phì';
  }
}
