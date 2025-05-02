import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/design/constants.dart';
import 'package:morflutter/info/emgClass.dart';
import 'package:morflutter/my_emg/MyCallibrationReading.dart';
import 'package:morflutter/my_emg/MyLiveChartScreen.dart';

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
    String? userUID = currentUser?.uid;

    String path = 'EMGData/$userUID/';

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Historial de lecturas',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              StreamBuilder(
                  stream: MorfoDatabase.child(path).onValue,
                  builder: (context, snapshot) {
                    /* 
                      Donde:
                        - snapshot: resultado del data stream.
                        Si no hay datos de firebase o aún está vacía la db:
                    
                    */
                    if (!snapshot.hasData ||
                        snapshot.data?.snapshot.value == null) {
                      return Center(
                        child: Text('No hay datos para mostrar.'),
                      );
                    }

                    // Convertir la info en un Map<>
                    final Map<dynamic, dynamic> rawData =
                        snapshot.data?.snapshot.value as Map<dynamic, dynamic>;

                    List<EMGData> lecturas = [];

                    // convertir en EMGData objects:
                    rawData.forEach((key, value) {
                      if (value is Map<dynamic, dynamic>) {
                        lecturas.add(EMGData.fromMap(
                            key, Map<String, dynamic>.from(value)));
                      }
                    });

                    lecturas.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                    // Convertir de EMGData a DataRow
                    List<DataRow> rows = lecturas.map((data) {
                      return DataRow(cells: [
                        DataCell(Text(data.timestamp)),
                        DataCell(Text(data.muscle)),
                        DataCell(Text(data.valor.toString())),
                        DataCell(Text(data.secs.toString())),
                      ]);
                    }).toList();

                    return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          height: 500,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(columns: [
                              // donde las columnas son fixed y las filas vienen del stream builder.
                              DataColumn(
                                  label: Text(
                                'Fecha',
                                style: TextStyle(color: darkPeriwinkle),
                              )),
                              DataColumn(
                                  label: Text(
                                'Musculo',
                                style: TextStyle(color: darkPeriwinkle),
                              )),
                              DataColumn(
                                  label: Text(
                                'Valor EMG',
                                style: TextStyle(color: darkPeriwinkle),
                              )),
                              DataColumn(
                                  label: Text(
                                'Seg',
                                style: TextStyle(color: darkPeriwinkle),
                              )),
                            ], rows: rows),
                          ),
                        ));
                  }),
              ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(darkPeriwinkle)),
                  child: Text('Real Time EMG',
                      style: TextStyle(color: Colors.white))),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyLiveChartScreenState()));
                  },
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(darkPeriwinkle)),
                  child: Text('Desktop EMG',
                      style: TextStyle(color: Colors.white))),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyCallibrationReading()));
                  },
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(darkPeriwinkle)),
                  child: Text('Callibration',
                      style: TextStyle(color: Colors.white)))
            ],
          ),
        ),
      ),
    );
  }
}
