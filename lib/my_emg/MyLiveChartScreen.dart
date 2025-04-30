import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/design/constants.dart';

class MyLiveChartScreenState extends StatefulWidget {
  const MyLiveChartScreenState({super.key});

  @override
  State<MyLiveChartScreenState> createState() => _MyLiveChartScreenStateState();
}

class _MyLiveChartScreenStateState extends State<MyLiveChartScreenState> {
  @override
  Widget build(BuildContext context) {
    // 1. Definimos los puntos a graficar (x = tiempo, y = voltaje)
    final List<FlSpot> points = [
      FlSpot(0, 0.5),
      FlSpot(1, 0.7),
      FlSpot(2, 1.3),
      FlSpot(3, 0.6),
      FlSpot(4, 0.4),
      FlSpot(5, 1.8),
      FlSpot(6, 0.9),
    ];
    return Scaffold(
      appBar: AppBar(title: Text('Demo EMG')),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: AspectRatio(
          aspectRatio: 1,
          child: LineChart(LineChartData(
              minY: 0,
              maxY: 2,
              titlesData: FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                    spots: points,
                    isCurved: true,
                    color: darkPeriwinkle,
                    barWidth: 3,
                    dotData: FlDotData(show: true))
              ])),
        ),
      ),
    );
  }
}
