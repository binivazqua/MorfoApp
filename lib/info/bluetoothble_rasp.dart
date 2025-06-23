import 'dart:async' as async;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class TestBLEScreen extends StatefulWidget {
  @override
  _TestBLEScreenState createState() => _TestBLEScreenState();
}

class _TestBLEScreenState extends State<TestBLEScreen> {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? espDevice;
  BluetoothCharacteristic? espCharacteristic;
  List<ScanResult> scanResults = [];
  bool isScanning = false;
  bool isConnected = false;

  final Guid serviceUUID = Guid("2E18CC93-EFBE-4927-AC92-0D229C122383");
  final Guid characteristicUUID = Guid("13909B07-0859-452F-AB6E-E5A4BC8D9DF4");

  late async.StreamSubscription<List<ScanResult>>? scanSubscription;

  void scanForDevices() async {
    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (!mounted)
        return; // verifica que el widget sigue siendo mostrado en la UI para evitar llamar a setState en un widget que ya no existe lol
      setState(() {
        scanResults = results
            .where((result) =>
                (result.device.advName.contains('ESP32')) ||
                (result.device.advName.contains('EMG')))
            .toList();
      });
    });

    await Future.delayed(Duration(seconds: 5));
    FlutterBluePlus.stopScan();
    await scanSubscription?.cancel();

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

            // Navigate to jsonReadingsPage
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => jsonReadingsPage(
                          characteristic: characteristic,
                        ))).then((_) {});
          }
        }
      }
    }
  }

  @override
  void dispose() {
    // Es totalemte válido usar dispose sin usar init.
    // TODO: implement dispose
    scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BLE JSON Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isScanning) CircularProgressIndicator(),
            if (!isConnected && !isScanning)
              ElevatedButton(
                onPressed: scanForDevices,
                child: Text("Buscar dispositivos"),
              ),
            if (!isConnected)
              ...scanResults.map((result) => ListTile(
                    title: Text(result.device.advName),
                    trailing: ElevatedButton(
                      onPressed: () => connectToDevice(result.device),
                      child: Text("Conectar"),
                    ),
                  )),
            if (isConnected) Text("Dispositivo conectado. Esperando datos..."),
          ],
        ),
      ),
    );
  }
}

class jsonReadingsPage extends StatefulWidget {
  final BluetoothCharacteristic characteristic;

  const jsonReadingsPage({
    super.key,
    required this.characteristic,
  });

  @override
  State<jsonReadingsPage> createState() => _jsonReadingsPageState();
}

class _jsonReadingsPageState extends State<jsonReadingsPage> {
  late async.StreamSubscription<List<int>> bleSubscription;
  String? lastJsonString;
  double? average;
  double? min;
  double? max;
  int? adc;
  String? state;

  @override
  void initState() {
    super.initState();
    bleSubscription = widget.characteristic.lastValueStream.listen((value) {
      print('Raw value received: $value');
      try {
        String jsonString = utf8.decode(value);
        print('Decoded JSON String: $jsonString');
        setState(() {
          lastJsonString = jsonString;
          final data = json.decode(jsonString);
          average = data['average']?.toDouble();
          min = data['min']?.toDouble();
          max = data['max']?.toDouble();
          adc = data['adc'];
          state = data['state'];
        });
      } catch (e) {
        print('Error decoding value: $e');
      }
    });
  }

  @override
  void dispose() {
    bleSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Datos JSON')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lastJsonString != null ? 'Datos:' : 'Esperando Datos'),
            Text('Average: ${average ?? "-"}'),
            Text('Min: ${min ?? "-"}'),
            Text('Max: ${max ?? "-"}'),
            Text('ADC: ${adc ?? "-"}'),
            Text('State: ${state ?? "-"}'),
            SizedBox(height: 20),
            Text('Raw JSON:'),
            Text(lastJsonString ?? '-'),
          ],
        ),
      ),
    );
  }
}
