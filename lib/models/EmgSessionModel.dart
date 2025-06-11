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
      'userId': userId,
      'sessionId': sessionId,
      'startTime': startTime,
      'durationSeconds': durationSeconds,
      'idealContractions': idealContractions,
      'lowerContractions': lowerContractions,
      'higherContractions': higherContractions,
      'minValue': minValue,
      'maxValue': maxValue,
      'targetValue': targetValue,
      'datapoints': datapoints.map((dp) => dp.toJSON()).toList(),
    };
  }

  factory EmgSession.fromJson(Map<String, dynamic> json) {
    return EmgSession(
      userId: json['userId'],
      sessionId: json['sessionId'],
      startTime: json['startTime'],
      durationSeconds: json['durationSeconds'],
      idealContractions: json['idealContractions'],
      lowerContractions: json['lowerContractions'],
      higherContractions: json['higherContractions'],
      minValue: json['minValue'].toDouble(),
      maxValue: json['maxValue'].toDouble(),
      targetValue: json['targetValue'].toDouble(),
      datapoints: (json['datapoints'] as List)
          .map((dp) => Datapoint.fromJson(dp))
          .toList(),
    );
  }
}
