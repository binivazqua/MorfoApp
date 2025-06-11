import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/animations/starCelebration.dart';
import 'package:morflutter/design/constants.dart';
import 'package:morflutter/models/DataPoint.dart';
import 'package:morflutter/my_emg/report/TimeStampReport.dart';

class MyLiveChartScreenState extends StatefulWidget {
  final min_value;
  final max_value;
  final target_value;
  const MyLiveChartScreenState(
      {super.key, this.min_value, this.max_value, this.target_value});

  @override
  State<MyLiveChartScreenState> createState() => _MyLiveChartScreenStateState();
}

class _MyLiveChartScreenStateState extends State<MyLiveChartScreenState> {
  List<FlSpot> emg_sim_data = [];
  double x = 0;
  Timer? timer;

  // Definir cronómetro de 10 segundos
  int durationSeconds = 5;
  DateTime startTime = DateTime.now();
  bool isRunning = true;

  // Retroalimentación visual
  late double threshold;
  String status = 'Reposo';
  Color currentColor = Colors.green;
  final double margin = 0.2;

  // conteo de contracciones:
  int ideal_contractions = 0;
  int lower_contractions = 0;
  int higher_contractions = 0;

  // conteo de tiempo de contracciones:
  List<DateTime> idealTimestamps = [];
  List<IdealContraction> idealContractions = [];
  DateTime? currentContractionStart;
  bool wasInTargetRange = false;

  // Lista de contracciones a Firestore:
  List<Datapoint> sessionData = [];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();

    // Inicializamos variables:
    threshold = widget.min_value;

    // Iniciar el timer -> simulación de una lectura cada 100 ms.
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!isRunning) return;

      // Loop logic -> are we done?
      final timeElapsed = DateTime.now().difference(startTime).inSeconds;
      if (timeElapsed >= durationSeconds) {
        setState(() => isRunning = false);
        timer?.cancel();

        // una vez terminado, mostramos la animación
        showSuccessAnimation(context);

        // esperamos un momento y mostramos el reporte
        Future.delayed(Duration(milliseconds: 2500), () {
          calculateStats();
        });
        return;
      }

      // Simuación del valor EMG
      final newValue = simulateEmgValue(); // reemplazar cuando BLE

      // lógica para actualizar el estado:
      final is_in_target_range = newValue >= widget.target_value - margin &&
          newValue <= widget.target_value + margin;
      // variables de texto para actualizar
      status = is_in_target_range ? 'En Rango' : 'Fuera de Rango';
      currentColor = is_in_target_range ? Colors.red : Colors.green;

      // Asignación de estatus por intensidad del valor EMG
      Datapoint point = Datapoint(
          value: newValue,
          date: DateTime.now(),
          intensity: status,
          muscleGroup: 'brachialis');

      sessionData.add(point);

      /* MANEJO DE TIPO DE CONTRACCIONES */
      // coantracciones ideales
      if (is_in_target_range) ideal_contractions++;

      /* Control de temporalidad 
      
        - is_in_target_range: valor actual está en rango ideal (?)
        - wasInTargetRange: valor pasado estuvo en rango ideal (?)
        - currentContractionStart: DateTime exacto en el que empezó la contracción ideal.
        - idealContractions: Lista que guarda cada contracción ideal como 
          una instancia de la clase IdealContraction, que contiene el tiempo 
          de inicio y duración.
      
      */

      // inicio de una contracción ideal (venimos del reposo)
      if (is_in_target_range && !wasInTargetRange) {
        currentContractionStart = DateTime.now();
      }
      // cambio de estado -> ya no en rango, pero sí estuvimos y su timestamp se almacenó.
      if (!is_in_target_range &&
          wasInTargetRange &&
          currentContractionStart != null) {
        // obtenemos su duración
        final duration = DateTime.now().difference(currentContractionStart!);
        idealContractions.add(
            // la alamacenamos
            IdealContraction(
                startTime: currentContractionStart!, duration: duration));

        // actualizamos la varibale para permitir nuevas mediciones
        currentContractionStart = null;
      }

      // actuzalizar estado:
      wasInTargetRange = is_in_target_range;

      // contracciones bajas:
      if (newValue < widget.target_value - margin) lower_contractions++;

      // contracciones altas:
      if (newValue > widget.target_value + margin) higher_contractions++;

      setState(() {
        emg_sim_data.add(FlSpot(x, newValue));
        x += 1;
        if (emg_sim_data.length > 100) emg_sim_data.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  double simulateEmgValue() {
    final random = Random();
    return random.nextDouble() < 0.1
        ? random.nextDouble() * 1.5 + 1.2
        : random.nextDouble() * 0.2 + 0.4;
  }

  void calculateStats() {
    if (emg_sim_data.isEmpty) return;

    // transformar la lista en una nueva lista que sólo contiene valor Y.
    double minY = emg_sim_data.map((e) => e.y).reduce(min);
    double maxY = emg_sim_data.map((e) => e.y).reduce(max);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                actionsAlignment: MainAxisAlignment.center,
                title: Text(
                  'Sesión finalizada',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                content: Text(
                    '¡Lo has hecho genial! Veamos tu reporte para continuar mejorando.'),
                actions: [
                  TextButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(lilyPurple)),
                      onPressed: () {
                        uploadDataToFirestore();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TimeStampReport(
                                      contractions: idealContractions,
                                    )));
                      },
                      child: Text(
                        'Ver Reporte',
                        style: TextStyle(color: Colors.black),
                      ))
                ]));
  }

  // Method to upload data to Firestore
  Future<void> uploadDataToFirestore() async {
    // detect user ID
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    if (userId == null) {
      print('User not logged in');
      return;
    }

    // Prepare data for Firestore
    try {
      final datapoints_json = sessionData.map((dp) => dp.toJSON()).toList();
      await FirebaseFirestore.instance
          .collection('emg_sessions')
          .doc(userId)
          .set({
        'user_id': userId,
        'session_id': sessionId,
        'start_time': startTime.toIso8601String(),
        'duration_seconds': durationSeconds,
        'ideal_contractions': ideal_contractions,
        'lower_contractions': lower_contractions,
        'higher_contractions': higher_contractions,
        'min_value': double.parse(widget.min_value.toStringAsFixed(2)),
        'max_value': double.parse(widget.max_value.toStringAsFixed(2)),
        'target_value': double.parse(widget.target_value.toStringAsFixed(2)),
        'datapoints': datapoints_json, // List of EMG data points
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Data uploaded successfully!'),
            duration: Duration(seconds: 2)),
      );
      print('Data uploaded successfully to Firestore.');
    } catch (e) {
      print('Error uploading data to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading data: $e'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    sessionData.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Demo EMG')),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Contracciones ideales: ${ideal_contractions}',
              style: TextStyle(
                  fontSize: 20,
                  color: darkPeriwinkle,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Bajas: ${lower_contractions}'),
                Text('Altas: ${higher_contractions}')
              ],
            ),
            SizedBox(
              height: 10,
            ),
            AspectRatio(
              aspectRatio: 1,
              child: LineChart(
                  // conjunto de líneas
                  LineChartData(
                      minY: 0,
                      maxY: 2,
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      rangeAnnotations: RangeAnnotations(
                        // Zona de esfuerzo ideal: cuando el valor EMG está entre 1.0 y 2.0V
// Se representa como una banda verde horizontal semitransparente.
// Ayuda al paciente a reconocer visualmente si su contracción fue eficaz.
                        horizontalRangeAnnotations: [
                          HorizontalRangeAnnotation(
                            y1: widget.target_value - margin,
                            y2: widget.target_value + margin,
                            color: Colors.green.shade100,
                          )
                        ],
                      ),
                      lineBarsData: [
                    //línea individual
                    LineChartBarData(
                        // puntos que conforman la línea
                        spots: emg_sim_data,
                        isCurved: true,
                        color: darkPeriwinkle,
                        barWidth: 3,
                        dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              /* 
                              spot -> punto a pintar
                              percent -> porcentaje recorrido de la línea (no se usa)
                              bar -> línea a la que pertenece el punto, (útil si tenemos varias líneas)}
                              index -> posición del punto en la lista.
                          */
                              final is_within_target_range =
                                  spot.y >= widget.min_value + margin;
                              return FlDotCirclePainter(
                                radius: 4,
                                color: is_within_target_range
                                    ? Colors.deepPurple
                                    : lilyPurple,
                                strokeWidth: 0,
                              );
                            })),
                  ])),
            ),
            Text(
              'Estado actual: $status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: currentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
