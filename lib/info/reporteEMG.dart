import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/design/constants.dart';
import 'package:morflutter/info/emgClass.dart';

class ReporteEMG extends StatefulWidget {
  const ReporteEMG({super.key});

  @override
  State<ReporteEMG> createState() => _ReporteEMGState();
}

class _ReporteEMGState extends State<ReporteEMG> {
  // DB DATA:
  final MorfoDatabase = FirebaseDatabase.instance.ref();

  // CURRENT USER DATA
  User? currentUser = FirebaseAuth.instance.currentUser;

  // DATA
  List<EMGData> EMGDataList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchEMGData();
  }

  void fetchEMGData() {
    String? userUID = currentUser?.uid;
    if (userUID == null) return; // ya accedió ?

    String path = 'EMGData/$userUID/';
    print('Recolectando datos EMG desde: $path');

    // Activate listeners:
    MorfoDatabase.child(path).onValue.listen((event) {
      if (event.snapshot.value != null) {
        // recibir los datos en crudo:
        final Map<dynamic, dynamic> rawData =
            event.snapshot.value as Map<dynamic, dynamic>;

        // creamos cajita de almacenamiento:
        List<EMGData> lecturas = [];

        // hacer uso de nuestro transformer:
        rawData.forEach((key, value) {
          // Volvemos a corroborar que sea map<dynamic, dynamic> tomando en cuenta que nuestro usuario tenga sólo una lectura -> crashearía.
          if (value is Map<dynamic, dynamic>) {
            // appendear haciendo uso del transformerm teniendo como key la timestamp y valor al sub-map.
            lecturas
                .add(EMGData.fromMap(key, Map<String, dynamic>.from(value)));
          }
        });

        // ordenar
        /*
          print(5.compareTo(10)); // Output: -1 (5 is smaller, so it should come before 10)
          print(10.compareTo(5)); // Output: 1  (10 is larger, so it should come after 5)
          print(5.compareTo(5));  // Output: 0  (Both are equal)

        */
        lecturas.sort((a, b) => b.timestamp.compareTo(
            a.timestamp)); // compareTo() determina el orden de sorteo de sort()

        // Updatear
        setState(() {
          EMGDataList = lecturas;
          print(EMGDataList.toString());
        });
      } else {
        print('No hay datos EMG para este usuario');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: lilyPurple,
        backgroundColor: draculaPurple,
        title: Image(
          width: 120,
          image: AssetImage(
              'lib/design/logos/principal_morado_negro-removebg-preview.png'),
        ),
      ),
      body: Column(),
    );
  }
}
