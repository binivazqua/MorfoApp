import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/models/PatientProfile.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  PatientProfile? profile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadProfile();
  }

  /*+++++++++++++++++ LOAD PROFILE +++++++++++++++++++++ */
  Future<void> loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    // encontrar colección en firestore
    final doc =
        await FirebaseFirestore.instance.collection('patients').doc(uid).get();

    // si se encuentra la colección:
    if (doc.exists) {
      // recolectar datos en formato JSON
      setState(() {
        profile = PatientProfile.fromJson(doc.data()!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: profile == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  Text("👤 ${profile!.name}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("🎂 Edad: ${profile!.age}"),
                  Text("⚧️ Género: ${profile!.gender}"),
                  Text(
                      "📆 Fecha diagnóstico: ${profile!.diagnosisDate.toLocal().toString().split(' ')[0]}"),
                  Text("📄 Diagnóstico: ${profile!.diagnosis}"),
                  Text("🎯 Objetivos: ${profile!.goal.join(', ')}"),
                  Text("💬 Síntomas: ${profile!.symptoms.join(', ')}"),
                  Text("😖 Nivel de dolor: ${profile!.painLevel}/5"),
                  SizedBox(height: 8),
                  Text("📝 Notas: ${profile!.notes}"),
                ],
              ));
  }
}
