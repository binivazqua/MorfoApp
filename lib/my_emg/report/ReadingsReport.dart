import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/models/EmgSessionModel.dart';

class ReadingsReport extends StatefulWidget {
  const ReadingsReport({super.key});

  @override
  State<ReadingsReport> createState() => _ReadingsReportState();
}

class _ReadingsReportState extends State<ReadingsReport> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth user = FirebaseAuth.instance;

  bool isloading = false;
  List<EmgSession> history_readings = [];

  @override
  void initState() {
    super.initState();
    fetchReadings();
  }

  Future<void> fetchReadings() async {
    setState(() {
      isloading = true;
    });

    try {
      final userId = user.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final snapshot = await firestore
          .collection('patients')
          .doc(userId)
          .collection('emg_sessions')
          .orderBy('start_time', descending: true) // Ordenar por fecha
          .get();

      // Query snapshot en lugar de snapshot ordinario
      if (snapshot.docs.isEmpty) {
        throw Exception('No readings found for this user');
      }

      // Convertir las data pieces en objetos EmgSession
      final List<EmgSession> readings = snapshot.docs.map((doc) {
        final data = doc.data();
        // extraer el array de datapoints
        final datapoints = data['datapoints'] as List<dynamic>? ?? [];
        // spread operador para combinar los datos del documento con los datapoints
        return EmgSession.fromJson({...data, 'datapoints': datapoints});
      }).toList();

      setState(() {
        history_readings = readings;
      });
    } catch (e) {
      print('Error fetching readings: $e');
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: isloading
            ? CircularProgressIndicator()
            : history_readings.isEmpty
                ? Text('No hay historial para este usuario')
                : ListView.builder(
                    itemBuilder: (context, index) {
                      final dp = history_readings[index];
                      return ListTile(
                        title: Text('Session ID: ${dp.sessionId}'),
                        subtitle: Text(
                            'Start Time: ${dp.startTime}\nDuration: ${dp.durationSeconds} seconds\nIdeal Contractions: ${dp.idealContractions}\nMin Value: ${dp.minValue}\nMax Value: ${dp.maxValue}\nTarget Value: ${dp.targetValue}'),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          // Navigate to session details or another screen if needed
                        },
                      );
                    },
                    itemCount: history_readings.length,
                  ));
  }
}
