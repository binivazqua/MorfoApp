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
  List<PieChartSectionData> _loadDistribution = [];
  int _time = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        _time++;
        _pressureData.add(FlSpot(_time.toDouble(), _random.nextDouble() * 100));
        _angleData.add(FlSpot(_time.toDouble(), _random.nextDouble() * 90));
        _temperatureData.add(
            FlSpot(_time.toDouble() * 1.0, _random.nextDouble() * 40 + 20));

        if (_pressureData.length > 20) {
          _pressureData.removeAt(0);
          _angleData.removeAt(0);
          _temperatureData.removeAt(0);
        }

        _loadDistribution = [
          PieChartSectionData(
              value: _random.nextDouble() * 50 + 1,
              color: Colors.blue,
              title: 'Pie derecho'),
          PieChartSectionData(
              value: _random.nextDouble() * 50 + 1,
              color: Color.fromARGB(255, 0, 106, 103),
              title: 'Pie izquierdo')
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'lib/design/renders/exoprintlogo.png',
          width: 180,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ' Rendimiento',
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(
                height: 10,
              ),
              _buildGraph(
                  "Presión", _angleData, Color.fromARGB(255, 0, 106, 103)),
              if (_loadDistribution.isNotEmpty)
                _buildBarChart("Inclinación al caminar", _loadDistribution),
              _buildPieChart("Distribución de peso"),
            ],
          ),
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title,
                  style: TextStyle(
                    fontSize: 18,
                  )),
            ),
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
                      color: color,
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

  Widget _buildBarChart(String title, List<PieChartSectionData> data) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title,
                  style: TextStyle(
                    fontSize: 18,
                  )),
            ),
            SizedBox(height: 10),
            Container(
              height: 150,
              child: BarChart(
                BarChartData(
                  barGroups: data.isNotEmpty
                      ? [
                          BarChartGroupData(x: 1, barRods: [
                            BarChartRodData(
                                toY: data[0].value, color: data[0].color)
                          ]),
                          BarChartGroupData(x: 2, barRods: [
                            BarChartRodData(
                                toY: data[1].value, color: data[1].color)
                          ]),
                        ]
                      : [],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(String title) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title,
                  style: TextStyle(
                    fontSize: 18,
                  )),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _loadDistribution,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
