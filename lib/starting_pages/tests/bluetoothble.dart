import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart'; // Needed for kIsWeb
import 'package:gif/gif.dart';
import 'dart:io';

import 'package:morflutter/design/constants.dart'; // Needed for platform-specific checks

class BLEScreen extends StatefulWidget {
  @override
  _BLEScreenState createState() => _BLEScreenState();
}

class _BLEScreenState extends State<BLEScreen> {
  FlutterBluePlus flutterBlue =
      FlutterBluePlus(); // instancia de BLE interactions
  BluetoothDevice? espDevice; // guarda al ESP después de escaneado
  BluetoothCharacteristic?
      espCharacteristic; // BLE characteristic -> comm channel donde se almacenan los datos.
  List<ScanResult> scanResults = []; // lista de dispositivos detectados
  String receivedData = "Sin datos";
  bool isScanning = false;
  bool isConnected = false;

  final Guid serviceUUID = Guid("2E18CC93-EFBE-4927-AC92-0D229C122383");
  final Guid characteristicUUID = Guid("13909B07-0859-452F-AB6E-E5A4BC8D9DF4");

  @override
  void initState() {
    super.initState();
    checkBluetoothSupport();
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
            espCharacteristic!.lastValueStream.listen((value) {
              setState(() {
                receivedData = String.fromCharCodes(value);
              });
            });
            break;
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
          receivedData = "Desconectado.";
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
                  child: Column(
                    children: [
                      Text("EMG:",
                          style:
                              TextStyle(fontSize: 20, color: darkPeriwinkle)),
                      SizedBox(height: 10),
                      Text(receivedData,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      if (espDevice != null)
                        ElevatedButton(
                          onPressed: disconnectDevice,
                          child: Text(
                            "Disconnect",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(lilyPurple)),
                        ),
                    ],
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
