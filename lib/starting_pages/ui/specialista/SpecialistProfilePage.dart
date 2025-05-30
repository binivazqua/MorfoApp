import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/components/patientInfoTile.dart';
import 'package:morflutter/design/constants.dart';
import 'package:morflutter/models/PatientProfile.dart';
import 'package:morflutter/services/PatientService.dart';

class SpecialistProfilePage extends StatefulWidget {
  final String doctorId;
  const SpecialistProfilePage({super.key, required this.doctorId});

  @override
  State<SpecialistProfilePage> createState() => _SpecialistProfilePageState();
}

class _SpecialistProfilePageState extends State<SpecialistProfilePage> {
  late Future<PatientProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = PatientService.loadProfile(widget.doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData) {
                return const Center(child: Text("No se encontró información"));
              }

              final profile = snapshot.data!;

              return Scaffold();
            }));
  }
}
