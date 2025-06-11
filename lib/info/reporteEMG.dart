import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/design/constants.dart';
import 'package:morflutter/info/emgClass.dart';
import 'package:morflutter/my_emg/MyCallibrationReading.dart';
import 'package:morflutter/my_emg/MyLiveChartScreen.dart';
import 'package:morflutter/my_emg/report/ReadingsReport.dart';

class ReadingsHomepage extends StatefulWidget {
  const ReadingsHomepage({super.key});

  @override
  State<ReadingsHomepage> createState() => _ReadingsHomepageState();
}

class _ReadingsHomepageState extends State<ReadingsHomepage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Lectura en Tiempo Real',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              IntrinsicWidth(
                stepWidth: 300,
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(darkPeriwinkle)),
                          child: Text('Real Time EMG',
                              style: TextStyle(color: Colors.white))),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MyLiveChartScreenState()));
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(darkPeriwinkle)),
                          child: const Text('Desktop EMG',
                              style: TextStyle(color: Colors.white))),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MyCallibrationReading()));
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(darkPeriwinkle)),
                          child: const Text('Callibration',
                              style: TextStyle(color: Colors.white))),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ReadingsReport()));
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(darkPeriwinkle)),
                          child: const Text('Reports',
                              style: TextStyle(color: Colors.white)))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
