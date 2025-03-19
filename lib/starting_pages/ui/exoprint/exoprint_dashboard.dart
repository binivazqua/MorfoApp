import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(ProstheticDashboardApp());
}

class ProstheticDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProstheticDashboard(),
    );
  }
}

class ProstheticDashboard extends StatefulWidget {
  @override
  _ProstheticDashboardState createState() => _ProstheticDashboardState();
}

class _ProstheticDashboardState extends State<ProstheticDashboard> {
  final Random _random = Random();
  List<FlSpot> _pressureData = [];
  List<FlSpot> _angleData = [];
  List<FlSpot> _temperatureData = [];
  int _time = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _time++;
        _pressureData.add(FlSpot(_time.toDouble(), _random.nextDouble() * 100));
        _angleData.add(FlSpot(_time.toDouble(), _random.nextDouble() * 90));
        _temperatureData
            .add(FlSpot(_time.toDouble(), _random.nextDouble() * 40 + 20));

        if (_pressureData.length > 20) {
          _pressureData.removeAt(0);
          _angleData.removeAt(0);
          _temperatureData.removeAt(0);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prosthetic Leg Dashboard"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _buildGraph("Pressure Sensor", _pressureData, Colors.red),
            _buildGraph("Angle Sensor", _angleData, Colors.green),
            _buildGraph("Temperature Sensor", _temperatureData, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildGraph(String title, List<FlSpot> data, Color color) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: Colors.red,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
