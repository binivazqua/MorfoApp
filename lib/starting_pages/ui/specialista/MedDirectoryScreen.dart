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

            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                // Evita scroll conflictivo
                itemCount: doctors.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.65,
                    mainAxisExtent: 250 // Ajusta según contenido
                    ),
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return SizedBox(
                    height: 100,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.all(6),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min, // se ajusta al contenido
                          children: [
                            const SizedBox(height: 8),
                            CircleAvatar(
                              backgroundImage: NetworkImage(doctor.photoUrl),
                              radius: 30,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              doctor.name,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor.speciality,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.deepPurple,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor.location,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: darkPeriwinkle,
                                  ),
                                  Icon(
                                    Icons.star_rounded,
                                    color: darkPeriwinkle,
                                  ),
                                  Icon(
                                    Icons.star_rounded,
                                    color: darkPeriwinkle,
                                  ),
                                  Icon(
                                    Icons.star_rounded,
                                    color: darkPeriwinkle,
                                  ),
                                  Icon(
                                    Icons.star_rounded,
                                    color: darkPeriwinkle,
                                  )
                                ],
                              ),
                            ),
                            // Empuja el botón al fondo
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text(
                                'Ver',
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: lilyPurple,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
