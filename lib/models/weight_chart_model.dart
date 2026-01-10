class WeightChartModel {
  final String date; // Format: YYYY-MM-DD
  final double weight;

  WeightChartModel({required this.date, required this.weight});

  factory WeightChartModel.fromJson(Map<String, dynamic> json) {
    return WeightChartModel(
      date: json['date'],
      weight: (json['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'weight': weight};
  }

  // Helper to parse date string to DateTime
  DateTime get dateTime {
    return DateTime.parse(date);
  }
}
