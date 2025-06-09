class Datapoint {
  final double value;
  final DateTime date;
  final String intensity;
  final String muscleGroup;

  Datapoint({
    required this.value,
    required this.date,
    required this.intensity,
    required this.muscleGroup,
  });

  // Convert to JSON (for uploading)
  Map<String, dynamic> toJSON() => {
        'value': value,
        'date': date.toIso8601String(),
        'muscleGroup': muscleGroup,
        'intensity': intensity,
      };

  // Create from JSON (when receiving from Firestore)
  factory Datapoint.fromJson(Map<String, dynamic> json) => Datapoint(
        value: json['value']?.toDouble() ?? 0.0,
        date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
        intensity: json['intensity'] ?? 'uknown',
        muscleGroup: json['muscleGroup'] ?? '',
      );
}
