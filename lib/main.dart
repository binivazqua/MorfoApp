import 'package:flutter/material.dart';

/* FIREBASE REQUIRED IMPORTS */
import 'package:firebase_core/firebase_core.dart';
import 'package:morflutter/display_info/sensorData.dart';
import 'package:morflutter/starting_pages/auth/loginPage.dart';
import 'package:morflutter/starting_pages/auth/mainPage.dart';
import 'package:morflutter/info/bluetoothble.dart';
import 'package:morflutter/starting_pages/tests/sendAndFetch.dart';
import 'package:morflutter/starting_pages/tests/tabSendData.dart';
import 'package:morflutter/starting_pages/ui/navigation/homeNavBar.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/*
void main() async {
  //void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MainApp());
}
// TO DEBUG: 

void main() {
  runApp(MainApp());
}
*/

// MORE SECURE INITIALIZATION BUILDER:
void main() async {
  //void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final Future<FirebaseApp> myApp = Firebase.initializeApp();

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    //return MaterialApp(home: MainPage());
    //return SendAndfetch();

    return MaterialApp(
      theme: ThemeData(fontFamily: 'Lausane400'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'), // Español
        Locale('en'), // Inglés
      ],
      home: FutureBuilder(
          future: myApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(
                  'There is a fuckin error around here: ${snapshot.error.toString()}');
              return Text('Somethin went wrong!!!');
            } else if (snapshot.hasData) {
              return MainPage();

              return MorfoHomeNavBar(); // PRUEBAS DE DEDITOS
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

// /sensorPWMREAL/pan9DKqEFxSE2vqhYuxOuP5FLa22/2024-09-08 10:15:55/valorPWM/-O6HPuPa6eLwwczXUyuY
