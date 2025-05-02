import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/design/constants.dart';

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
  int durationSeconds = 10;
  DateTime startTime = DateTime.now();
  bool isRunning = true;

  // Retroalimentación visual
  double threshold = 0.8;
  String status = 'Reposo';
  Color currentColor = Colors.green;

  // 1. Definimos los puntos a graficar (x = tiempo, y = voltaje)
  /*
    final List<FlSpot> points = [
      FlSpot(0, 0.5),
      FlSpot(1, 0.7),
      FlSpot(2, 1.3),
      FlSpot(3, 0.6),
      FlSpot(4, 0.4),
      FlSpot(5, 1.8),
      FlSpot(6, 0.9),
    ];*/

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();

    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!isRunning) return;

      final timeElapsed = DateTime.now().difference(startTime).inSeconds;
      if (timeElapsed >= durationSeconds) {
        setState(() => isRunning = false);
        timer?.cancel();
        calculateStats(); // ← ve al paso 3
        return;
      }

      final newValue = simulateEmgValue(); // reemplazar cuando BLE
      // variables de texto para actualizar
      status = newValue > threshold ? 'Contracción' : 'Reposo';
      currentColor = newValue > threshold ? Colors.red : Colors.green;
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
                title: Text('Sesión finalizada'),
                content: Text(
                  'Valor mínimo: ${minY.toStringAsFixed(2)} V\n'
                  'Valor máximo: ${maxY.toStringAsFixed(2)} V',
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cerrar'))
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Demo EMG')),
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
                        horizontalRangeAnnotations: [
                          HorizontalRangeAnnotation(
                            y1: 1.0,
                            y2: 2.0,
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
                              final isAboveThreshold = spot.y >= threshold;
                              return FlDotCirclePainter(
                                radius: 4,
                                color: isAboveThreshold
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
