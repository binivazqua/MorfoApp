import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/animations/starCelebration.dart';
import 'package:morflutter/design/constants.dart';
import 'package:morflutter/my_emg/MyLiveChartScreen.dart';

class MyCallibrationReading extends StatefulWidget {
  const MyCallibrationReading({super.key});

  @override
  State<MyCallibrationReading> createState() => _MyCallibrationReadingState();
}

class _MyCallibrationReadingState extends State<MyCallibrationReading> {
  List<FlSpot> emg_sim_data = [];
  double x = 0;
  Timer? timer;

  // Variables de calibración
  /*
    // Inicialización para calibración:
    // max_value comienza en 0.0 para permitir detectar valores más altos durante la sesión.
    / min_value comienza en un número muy alto para ser reemplazado por valores reales bajos.
    // Así garantizamos que ambos valores se ajusten correctamente al comportamiento real del paciente.
*/
  bool isCalibration = true;
  double min_value = 999.0;
  double max_value = 0.0; // loop override
  double target_value = 0.0;
  double target_margin = 0.2; // margen del target para zona de rangeAnnotation

  // Definir cronómetro de 10 segundos
  int durationSeconds = 5;
  DateTime startTime = DateTime.now();

  // Retroalimentación visual
  double threshold = 0.8;
  String status = 'Reposo';
  Color currentColor = Colors.green;

  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();

    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final timeElapsed = DateTime.now().difference(startTime).inSeconds;
      final newValue = simulateEmgValue(); // reemplazar cuando BLE

      // calibradning
      if (isCalibration && timeElapsed < durationSeconds) {
        // Obtención de máximos y mínimos
        if (newValue > max_value) max_value = newValue;
        if (newValue < min_value) min_value = newValue;
        target_value =
            (max_value + min_value) / 2; // nuestro target es un promedio
      }
      /*
           Verifica si el nuevo valor EMG está dentro del rango objetivo personalizado.
           Este rango se define a partir de target_value,
           ± un margen de tolerancia (goal_margin). Si el valor se encuentra dentro de ese rango,
           se considera que el paciente está ejecutando una contracción con intensidad adecuada,
           y se activa el biofeedback positivo.
      */

      // progreso:
      setState(() {
        progress = timeElapsed / durationSeconds;
      });
      // Calibración completada
      if (timeElapsed >= durationSeconds && isCalibration) {
        setState(() => isCalibration = false);
        timer?.cancel();
        showSuccessAnimation(context);

        Future.delayed(Duration(milliseconds: 2500), () {
          calculateStats();
        });

        return;
      }

      // prevención de overflow
      setState(() {
        emg_sim_data.add(FlSpot(x, newValue));
        x += 1;
        if (emg_sim_data.length > 100) emg_sim_data.removeAt(0);
        // control del progreso de la sesión
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

  Widget _buildStatRow(IconData icon, String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: darkPeriwinkle),
          const SizedBox(width: 10),
          Text(
            '$label ${value.toStringAsFixed(2)} V',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void calculateStats() {
    if (emg_sim_data.isEmpty) return;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                actionsAlignment: MainAxisAlignment.center,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Text(
                  '¡Calibración completada!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatRow(
                        Icons.arrow_downward, 'Reposo mínimo:', min_value),
                    _buildStatRow(
                        Icons.arrow_upward, 'Contracción máxima:', max_value),
                    _buildStatRow(
                        Icons.arrow_downward, 'Objetivo:', target_value),
                  ],
                ),
                actions: [
                  TextButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(lilyPurple)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyLiveChartScreenState(
                                      min_value: min_value,
                                      max_value: max_value,
                                      target_value: target_value,
                                    )));
                      },
                      child: Text(
                        '¡Comenzar!',
                        style: TextStyle(color: Colors.black),
                      ))
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calibration Phase')),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Center(
          child: Column(
            children: [
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
                          )),
                    ])),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: LinearProgressIndicator(
                  value: progress,
                  color: darkPeriwinkle,
                  backgroundColor: Colors.grey,
                  minHeight: 30,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% completado.',
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
        ),
      ),
    );
  }
}
