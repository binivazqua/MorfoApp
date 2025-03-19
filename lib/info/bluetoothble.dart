import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart'; // Needed for kIsWeb
import 'package:gif/gif.dart';
import 'dart:io';

import 'package:morflutter/design/constants.dart';
import 'package:morflutter/info/reporteEMG.dart'; // Needed for platform-specific checks

class BLEScreen extends StatefulWidget {
  @override
  _BLEScreenState createState() => _BLEScreenState();
}

class _BLEScreenState extends State<BLEScreen> {
  // FIREBASE:
  final MorfoDatabase = FirebaseDatabase.instance.ref('EMGData');
  User? newUser = FirebaseAuth.instance.currentUser;

  // BLE:
  FlutterBluePlus flutterBlue =
      FlutterBluePlus(); // instancia de BLE interactions
  BluetoothDevice? espDevice; // guarda al ESP después de escaneado
  BluetoothCharacteristic?
      espCharacteristic; // BLE characteristic -> comm channel donde se almacenan los datos.

  // ADDITIONAL:
  List<ScanResult> scanResults = []; // lista de dispositivos detectados
  int receivedData = 0;
  bool isScanning = false;
  bool isConnected = false;

  final Guid serviceUUID = Guid("2E18CC93-EFBE-4927-AC92-0D229C122383");
  final Guid characteristicUUID = Guid("13909B07-0859-452F-AB6E-E5A4BC8D9DF4");

  @override
  void initState() {
    super.initState();
    checkBluetoothSupport();
  }

  Future<void> sendEMGData() async {
    String _timestamp = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-'); // Formato sumamente específico.
    String _timestampred = DateTime.now().second.toString();
    String? userUID = newUser?.uid;
    String path = '$userUID/$_timestamp';
    print(path);

    try {
      await MorfoDatabase.child(path).set({
        'Tiempo': _timestampred,
        'Valor': receivedData,
        'Musculo': 'M1',
      });
      print('Valores EMG enviados satisfactoriamente');
    } catch (error) {
      print('Datos EMG no enviados. Error: ${error}');
    }
  }

  Future<void> checkBluetoothSupport() async {
    if (await FlutterBluePlus.isSupported == false) {
      print("La función Bluetooth no está disponible en este dispositivo.");
      return;
    }

    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print("Estado de Bluetooth: $state");
      if (state == BluetoothAdapterState.on) {
        scanForDevices();
      } else {
        print("Por favor, habilita la función Bluetooth para continuar.");
      }
    });

    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  void scanForDevices() async {
    setState(() {
      isScanning = true;
      scanResults.clear(); // update en rt de los dispositivos detectados
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results
            .where((result) =>
                (result.device.advName.contains('ESP')) ||
                (result.device.advName.contains('Orion')))
            .toList();
      });
    });

    await Future.delayed(Duration(seconds: 5)); // tiempo de delay
    FlutterBluePlus.stopScan();

    setState(() {
      isScanning = false;
    });
  }

  int _convertToInt(List<int> value) {
    if (value.length == 1) {
      return value[0]; // Single-byte integer (0-255)
    } else if (value.length == 2) {
      return (value[1] << 8) | value[0]; // 16-bit integer (0-65535)
    } else if (value.length == 4) {
      return (value[3] << 24) |
          (value[2] << 16) |
          (value[1] << 8) |
          value[0]; // 32-bit integer
    }
    return 0; // Default if format is unexpected
  }

  void connectToDevice(BluetoothDevice device) async {
    setState(() {
      espDevice = device;
      isConnected = true;
    });

    await espDevice!.connect();
    print("Conectado a ${device.advName}");

    List<BluetoothService> services = await espDevice!.discoverServices();
    for (var service in services) {
      if (service.uuid == serviceUUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid == characteristicUUID) {
            espCharacteristic = characteristic;
            await espCharacteristic!.setNotifyValue(true);

            // Real time stream updateess
            StreamController<int> emgController = StreamController<int>();

            // ✅ Listen for BLE data
            StreamSubscription<List<int>> bleSubscription =
                espCharacteristic!.lastValueStream.listen((value) {
              int emgValue = _convertToInt(value);

              setState(() {
                receivedData = emgValue;
                sendEMGData();
              });

              // ✅ Send data to the graph
              if (!emgController.isClosed) {
                emgController.add(emgValue);
              }
            });

            // ir a página de graph
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GraphicScreen(emgStream: emgController.stream)))
                .then((_) {
              emgController.close();
              bleSubscription.cancel();
            });
          }
        }
      }
    }
  }

  // desconexión total de la esp32 y resetea las variables
  void disconnectDevice() async {
    if (espDevice != null) {
      bool _really_disconect = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("¿Desconectar?"),
              content:
                  Text('¿Estás seguro de que quieres desconectarte de Orión?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: lilyPurple),
                    )),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Aceptar',
                      style: TextStyle(color: darkPeriwinkle),
                    )),
              ],
            );
          });

      if (_really_disconect) {
        await espDevice!.disconnect();
        setState(() {
          espDevice = null;
          receivedData = 0;
        });
      }
    }
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Positioned(
              top: 20,
              child: Text(
                '¡Estás a un paso!',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isScanning)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Gif(
                      image: AssetImage('lib/design/renders/scanning.gif'),
                      placeholder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                      autostart: Autostart.loop,
                    ),
                  ),
                // Scanning Button
                if (isScanning || !isConnected)
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(darkPeriwinkle),
                        foregroundColor: WidgetStatePropertyAll(Colors.white)),
                    onPressed: isScanning
                        ? null
                        : scanForDevices, // si está escaneando, el botón queda inhabilitado.
                    child: isScanning ? Text("Buscando...") : Text("Conectar"),
                  ),

                // Device List
                if (!isConnected)
                  Container(
                    height: 200,
                    child: ListView.builder(
                      itemCount: scanResults.length,
                      itemBuilder: (context, index) {
                        BluetoothDevice device = scanResults[index]
                            .device; // 1 device per scan to access sus propiedades
                        return ListTile(
                          title: Text(device.advName.contains("ESP")
                              ? device.advName
                              : "Desconocido"),
                          trailing: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(lilyPurple)),
                            onPressed: () => connectToDevice(device),
                            child: Text(
                              "Conectar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Received Data Display
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("EMG:",
                            style:
                                TextStyle(fontSize: 20, color: darkPeriwinkle)),
                        SizedBox(height: 10),
                        Text(receivedData.toString(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),
                        if (isConnected)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 10,
                            children: [
                              ElevatedButton(
                                onPressed: disconnectDevice,
                                child: Text(
                                  "Desconectar",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll(lilyPurple)),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ReporteEMG()));
                                },
                                child: Text(
                                  "Gráficos",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll(lilyPurple)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GraphicScreen extends StatefulWidget {
  final Stream<int> emgStream; // async data handling from ble

  GraphicScreen({required this.emgStream});

  @override
  _GraphicScreenState createState() => _GraphicScreenState();
}

/* ====================== MAX VALUE NOTIFIER ==================== */

double findMaxValue(List<FlSpot> spots) {
  if (spots.isEmpty) return 0.0; // no crash

  double maxValue = spots[0].y; // primer valor
  for (FlSpot spot in spots) {
    if (spot.y > maxValue) {
      maxValue = spot.y; // nuevo valor encontrado?
    }
  }
  return maxValue;
}

void showMaxValueDialog(BuildContext context, double maxValue) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Valor máximo encontrado:"),
        content: Text("El valor máximo es: $maxValue"),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}
/* ================================================================= */

class _GraphicScreenState extends State<GraphicScreen> {
  List<FlSpot> emgGraphData = [];
  int counter = 0;
  StreamSubscription<int>? emgSubscription;
  double? lastMaxValue; // Stores the last max value to avoid duplicate alerts

  Timer? readingTimer; // ✅ Controls the 10-second reading session
  bool isReadingActive = false; // ✅ Prevents duplicate readings

  @override
  void initState() {
    super.initState();

    isReadingActive = true; // ✅ Activate reading session

    // Start 10-second timer
    readingTimer = Timer(Duration(seconds: 10), () {
      if (mounted) {
        isReadingActive = false; // ✅ Stop recording
        emgSubscription?.cancel(); // ✅ Stop BLE readings

        double maxValue = findMaxValue(emgGraphData); // ✅ Find max value

        // ✅ Show alert after 10 seconds
        showMaxValueDialog(context, maxValue);
      }
    });

    // ✅ Listen to EMG stream during the reading session
    emgSubscription = widget.emgStream.listen((emgValue) {
      if (!mounted || !isReadingActive)
        return; // ✅ Stop updating if session ends

      setState(() {
        emgGraphData.add(FlSpot(counter.toDouble(), emgValue.toDouble()));
        counter++;

        if (emgGraphData.length > 30) {
          emgGraphData.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    emgSubscription?.cancel(); // ✅ Stop listening to BLE
    readingTimer?.cancel(); // ✅ Cancel the reading timer
    super.dispose();
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
                  'lib/design/logos/principal_morado_negro-removebg-preview.png')),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'Datos EMG',
                style: TextStyle(fontSize: 25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: LineChart(LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                          spots: emgGraphData,
                          isCurved: true,
                          barWidth: 3,
                          color: lilyPurple,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: true))
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 30)),
                      bottomTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    backgroundColor: Colors.black)),
              ),
            ),
          ],
        ));
  }
}
