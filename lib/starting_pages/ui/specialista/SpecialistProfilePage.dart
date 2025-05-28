import 'package:flutter/material.dart';
import 'package:morflutter/models/DoctorProfile.dart';

class SpecialistProfilePage extends StatefulWidget {
  const SpecialistProfilePage({super.key});

  @override
  State<SpecialistProfilePage> createState() => _SpecialistProfilePageState();
}

class _SpecialistProfilePageState extends State<SpecialistProfilePage> {
  DoctorProfile? profile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nombre del Especialista'),
      ),
      body: Column(
        children: [
          Container(
            child: Column(
              children: [CircleAvatar()],
            ),
          )
        ],
      ),
    );
  }
}
