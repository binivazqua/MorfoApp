import 'package:flutter/material.dart';
import 'package:morflutter/design/constants.dart';
import 'package:morflutter/models/DoctorProfile.dart';
import 'package:morflutter/services/DoctorService.dart';
import 'package:morflutter/starting_pages/ui/specialista/SpecialistProfilePage.dart';

class MedDirectoryScreen extends StatefulWidget {
  const MedDirectoryScreen({super.key});

  @override
  State<MedDirectoryScreen> createState() => _MedDirectoryScreenState();
}

class _MedDirectoryScreenState extends State<MedDirectoryScreen> {
  late Future<List<DoctorProfile>> doctorList;
  TextEditingController _searchController = TextEditingController();

  List<DoctorProfile> _filteredDoctors = [];
  String _selectedFilter = 'Todos';
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

            // inicializamos nuestra lista filtrada con todos los datos, esto
            // porque es la lista que usaremos en el GridView.
            final doctors = snapshot.data!;
            if (_filteredDoctors.isEmpty) {
              _filteredDoctors = doctors;
            }

            // creamos lista de filtros}
            // Crea una lista que comience con 'Todos', y luego añade una vez cada especialidad distinta que haya en la lista doctors
            // ...{} -> set en list
            final specialities = [
              'Todos',
              ...{for (final d in doctors) d.speciality}
            ];

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        setState(() {
                          _filteredDoctors = doctors.where((doctor) {
                            final name = doctor.name.toLowerCase();
                            final speciality = doctor.speciality.toLowerCase();
                            final location = doctor.location.toLowerCase();
                            // valor de nuestra búsqueda
                            final search = query.toLowerCase();

                            // asignamos nuestra lista filtrada a los valores que coinciden:
                            return name.contains(search) ||
                                speciality.contains(search) ||
                                location.contains(search);
                          }).toList();
                        });
                      },
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                          hintText: 'Busca un especialista...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: specialities.map((speciality) {
                            final isSelected = _selectedFilter == speciality;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(speciality),
                                selected: isSelected,
                                // el callback de un ChoiceChip que se ejecuta cuando el usuario toca ese chip.
                                onSelected: (_) {
                                  // este setState() asigna nuestra lista base de doctores que se mostrarán en la UI.
                                  setState(() {
                                    _selectedFilter = speciality; // chip activo
                                    _filteredDoctors = doctors.where((doctor) {
                                      // filtro similar al de SearchBar, conserva los docs que:
                                      // Coinciden con lo que escribió el usuario (matchesSearch)
                                      // Coinciden con el chip seleccionado (matchesFilter)
                                      final matchesSearch = doctor.name
                                              .toLowerCase()
                                              .contains(_searchController.text
                                                  .toLowerCase()) ||
                                          doctor.speciality
                                              .toLowerCase()
                                              .contains(_searchController.text
                                                  .toLowerCase()) ||
                                          doctor.location
                                              .toLowerCase()
                                              .contains(_searchController.text
                                                  .toLowerCase());

                                      final matchesFilter =
                                          speciality == 'Todos'
                                              ? true
                                              : doctor.speciality == speciality;

                                      return matchesSearch && matchesFilter;
                                    }).toList();
                                  });
                                },
                                selectedColor: Colors.deepPurple.shade100,
                                backgroundColor: Colors.grey.shade200,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 5),
                      child: Text(
                        'Expertos Morfo',
                        style: TextStyle(
                            fontSize: 20,
                            color: darkPeriwinkle,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _filteredDoctors.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.65,
                              mainAxisExtent: 250 // Ajusta según contenido
                              ),
                      itemBuilder: (context, index) {
                        final doctor = _filteredDoctors[index];
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
                                    backgroundImage:
                                        NetworkImage(doctor.photoUrl),
                                    radius: 30,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    doctor.name,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SpecialistProfilePage()));
                                    },
                                    child: const Text(
                                      'Ver',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: lilyPurple,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
