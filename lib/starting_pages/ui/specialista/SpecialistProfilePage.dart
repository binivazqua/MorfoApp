import 'package:flutter/material.dart';
import 'package:morflutter/models/DoctorProfile.dart';
import 'package:morflutter/services/DoctorService.dart';

class SpecialistProfilePage extends StatelessWidget {
  final String doctorId;
  const SpecialistProfilePage({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DoctorProfile>(
        future: DoctorService.loadProfile(doctorId),
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
        });
  }
}
