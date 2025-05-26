import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/components/patientInfoTile.dart';
import 'package:morflutter/design/constants.dart';
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
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: lilyPurple),
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.person_2,
                            color: draculaPurple,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          profile!.name,
                          style: TextStyle(fontSize: 20),
                        ),
                        PatientInfoTile(
                            value: profile!.age.toString(), parameter: 'Edad:'),
                        PatientInfoTile(
                            value: profile!.gender, parameter: 'Género:'),
                        PatientInfoTile(
                            value: profile!.diagnosis,
                            parameter: 'Diagnóstico:'),
                        PatientInfoTile(
                            value: profile!.diagnosisDate
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                            parameter: 'Fecha de diagnóstico:'),
                        PatientInfoTile(
                            value: profile!.painLevel.toString(),
                            parameter: 'Nivel de dolor:'),
                        PatientInfoTile(
                            value: profile!.symptoms.join('\n'),
                            parameter: 'Síntomas:'),
                        PatientInfoTile(
                            value: profile!.goal.join('\n'),
                            parameter: 'Objetivos:'),
                        PatientInfoTile(
                            value: profile!.notes, parameter: 'Notas:'),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
