import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/components/patientInfoTile.dart';
import 'package:morflutter/design/constants.dart';
import 'package:morflutter/models/PatientProfile.dart';
import 'package:morflutter/services/PatientService.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  late Future<PatientProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _profileFuture = PatientService.loadProfile(uid);
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

              return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Center(
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
                        ElevatedButton(onPressed: () {}, child: Text('Editar'))
                      ],
                    ),
                  ));
            }));
  }
}

/*
  profile == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
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
                          value: profile!.diagnosis, parameter: 'Diagnóstico:'),
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
                      ElevatedButton(onPressed: () {}, child: Text('Editar'))
                    ],
                  ),
                ),
              ));


 */
