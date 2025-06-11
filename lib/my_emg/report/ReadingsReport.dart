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
  List<Map<String, dynamic>> readings = [];

  Future<List<EmgSession>> fetchReadings() async {
    setState(() {
      isloading = true;
    });

    try {
      final userId = user.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final snapshot =
          await firestore.collection('emg_sessions').doc(userId).get();

      if (!snapshot.exists) {
        throw Exception('No readings found for this user');
      }

      final data = snapshot.data();
      final List<dynamic> readingsData = data?['datapoints'] ?? [];

      return readingsData
          .map(
              (reading) => EmgSession.fromJson(reading as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching readings: $e');
      return [];
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Readings Report')],
        ),
      ),
    );
  }
}
