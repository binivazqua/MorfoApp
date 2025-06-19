import 'package:morflutter/models/DataPoint.dart';

class EmgSession {
  final String userId;
  final String sessionId;
  final String startTime;
  final int durationSeconds;
  final int idealContractions;
  final int lowerContractions;
  final int higherContractions;
  final double minValue;
  final double maxValue;
  final double targetValue;
  final List<Datapoint> datapoints;

  EmgSession({
    required this.userId,
    required this.sessionId,
    required this.startTime,
    required this.durationSeconds,
    required this.idealContractions,
    required this.lowerContractions,
    required this.higherContractions,
    required this.minValue,
    required this.maxValue,
    required this.targetValue,
    required this.datapoints,
  });

  // Create a Map function that converts the object to a JSON structure
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'session_id': sessionId,
      'start_time': startTime,
      'duration_seconds': durationSeconds,
      'ideal_contractions': idealContractions,
      'lower_contractions': lowerContractions,
      'higher_contractions': higherContractions,
      'min_value': minValue,
      'max_value': maxValue,
      'target_value': targetValue,
      'datapoints': datapoints.map((dp) => dp.toJSON()).toList(),
    };
  }

  factory EmgSession.fromJson(Map<String, dynamic> json) {
    return EmgSession(
      userId: json['user_id'],
      sessionId: json['session_id'],
      startTime: json['start_time'],
      durationSeconds: json['duration_seconds'],
      idealContractions: json['ideal_contractions'],
      lowerContractions: json['lower_contractions'],
      higherContractions: json['higher_contractions'],
      minValue: json['min_value'].toDouble(),
      maxValue: json['max_value'].toDouble(),
      targetValue: json['target_value'].toDouble(),
      datapoints: (json['datapoints'] as List)
          .map((dp) => Datapoint.fromJson(dp))
          .toList(),
    );
  }
}
