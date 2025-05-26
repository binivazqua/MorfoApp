import 'package:flutter/material.dart';
import 'package:morflutter/design/constants.dart';
import 'package:morflutter/models/DoctorProfile.dart';
import 'package:morflutter/services/DoctorService.dart';

class MedDirectoryScreen extends StatefulWidget {
  const MedDirectoryScreen({super.key});

  @override
  State<MedDirectoryScreen> createState() => _MedDirectoryScreenState();
}

class _MedDirectoryScreenState extends State<MedDirectoryScreen> {
  late Future<List<DoctorProfile>> doctorList;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    doctorList = DoctorService.fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lilyPurple,
        title: Image(
            image: AssetImage(
              'lib/design/logos/rectangular_vino_trippypurplep.png',
            ),
            width: 120),
      ),
      body: FutureBuilder(
          future: doctorList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error obteniendo datos.'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('No hay datos para mostrar.'),
              );
            }

            final doctors = snapshot.data!;

            return ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: doctor.photoUrl != null
                          ? NetworkImage(doctor.photoUrl)
                          : null,
                      child: doctor.photoUrl == null
                          ? Icon(Icons.person_2_outlined)
                          : null,
                    ),
                    title: Text(doctor.name),
                    subtitle: Text('${doctor.speciality} | ${doctor.location}'),
                  );
                });
          }),
    );
  }
}
