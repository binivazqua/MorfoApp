import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/components/patientInfoTile.dart';
import 'package:morflutter/design/constants.dart';
import 'package:morflutter/models/DoctorProfile.dart';
import 'package:morflutter/models/PatientProfile.dart';
import 'package:morflutter/services/DoctorService.dart';
import 'package:morflutter/services/PatientService.dart';

class SpecialistProfilePage extends StatefulWidget {
  final String doctorId;
  const SpecialistProfilePage({super.key, required this.doctorId});

  @override
  State<SpecialistProfilePage> createState() => _SpecialistProfilePageState();
}

class _SpecialistProfilePageState extends State<SpecialistProfilePage> {
  late Future<DoctorProfile> _profileFuture;
  late final String doctorId = widget.doctorId;

  @override
  void initState() {
    super.initState();
    _profileFuture = DoctorService.loadProfile(doctorId);
    print('Received doctorId: ${doctorId}');
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

              return Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          profile.photoUrl,
                        ),
                        radius: 60,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Dr. ${profile.name}',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        profile.speciality,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: 300,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 5,
                                children: [
                                  Icon(
                                    Icons.location_city_outlined,
                                    color: darkPeriwinkle,
                                  ),
                                  Text(
                                    profile.location,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    profile.hospital,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Row(
                              children: [
                                Text('5.0'),
                                Icon(
                                  Icons.star_outline_rounded,
                                  color: darkPeriwinkle,
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          width: 380,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Descripción',
                                style: TextStyle(
                                    fontSize: 18, color: darkPeriwinkle),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                profile.description,
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'Pacientes',
                                style: TextStyle(
                                    fontSize: 18, color: darkPeriwinkle),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                    color: Colors.purple[50],
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  spacing: 10,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: CircleAvatar(
                                        radius: 20,
                                        child: Icon(Icons.person_2_rounded),
                                      ),
                                    ),
                                    patientCard(
                                        'Abigail Santiago',
                                        'Excelente terapeuta, con muy buen trato y calidez a los pacientes',
                                        '27/05/2025')
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  Widget patientCard(String name, String opinion, String date) {
    return SizedBox(
      width: 320,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: darkPeriwinkle,
                        size: 10,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: darkPeriwinkle,
                        size: 10,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: darkPeriwinkle,
                        size: 10,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: darkPeriwinkle,
                        size: 10,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: darkPeriwinkle,
                        size: 10,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '5.0',
                        style: TextStyle(fontSize: 10),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Text(
              date,
              style: TextStyle(fontSize: 10, color: darkPeriwinkle),
            ),
            Text(
              opinion,
              overflow: TextOverflow.clip,
              style: TextStyle(color: Colors.grey, fontSize: 10),
            )
          ],
        ),
      ),
    );
  }
}
