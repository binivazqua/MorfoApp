import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
  int durationSeconds = 10;
  DateTime startTime = DateTime.now();

  // Retroalimentación visual
  double threshold = 0.8;
  String status = 'Reposo';
  Color currentColor = Colors.green;

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

      // Calibración completada
      if (timeElapsed >= durationSeconds && isCalibration) {
        setState(() => isCalibration = false);
        timer?.cancel();
        calculateStats();
        return;
      }

      // prevención de overflow
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

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: Text('Calibración completa'),
                content: Text(
                    'Contracción máxima: ${max_value.toStringAsFixed(2)} V\n'
                    'Reposo mínimo: ${min_value.toStringAsFixed(2)} V\n'
                    'Valor objetivo: ${target_value.toStringAsFixed(2)}'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MyLiveChartScreenState()));
                      },
                      child: Text('¡Comenzar!'))
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calibration Phase')),
      body: Padding(
        padding: EdgeInsets.all(8),
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
          ],
        ),
      ),
    );
  }
}
