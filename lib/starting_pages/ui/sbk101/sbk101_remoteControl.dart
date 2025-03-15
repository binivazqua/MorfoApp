import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/design/constants.dart';

class SBK101RemoteControl extends StatefulWidget {
  const SBK101RemoteControl({super.key});

  @override
  State<SBK101RemoteControl> createState() => _SBK101RemoteControlState();
}

class _SBK101RemoteControlState extends State<SBK101RemoteControl> {
  // STEP 1: INITIALIZE FIREBASE DATABASE
  final database = FirebaseDatabase.instance.ref();

  // Variables to control the toggle colors.
  bool isToggledPulgar = false;
  bool isToggledIndice = false;
  bool isToggledMedio = false;
  bool isToggledAnular = false;
  bool isToggledMenique = false;

  Color fingerColorOpen = lilyPurple;
  Color fingerColorClosed = darkPeriwinkle;

  String handStatus = "Abierta";
  IconData mano_cerrada = Icons.front_hand_outlined;
  IconData mano_abierta = Icons.front_hand_outlined;

  bool abierta = false;

  @override
  Widget build(BuildContext context) {
    // DESIRED PATHX:
    final testWrite =
        database.child('MidasControl/'); // MAKE SURE U HAVE '/' in there!

    return Scaffold(
      appBar: AppBar(
        backgroundColor: lilyPurple,
        title: Image(
            image: AssetImage(
              'lib/design/logos/rectangular_vino_trippypurplep.png',
            ),
            width: 120),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Controla tu SBK1-01',
                style: TextStyle(fontSize: 20),
              ),
              Text("De forma remota"),
              SizedBox(
                height: 20,
              ),
              Text("Control individual"),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          onPressed: () => sendFingerCommand('Pulgar'),
                          icon: Icon(Icons.fingerprint_rounded),
                          iconSize: 40,
                          color: isToggledPulgar ? draculaPurple : lilyPurple,
                        ),
                        Text("Pulgar")
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                            onPressed: () => sendFingerCommand('Indice'),
                            icon: Icon(Icons.fingerprint_rounded),
                            iconSize: 40,
                            color:
                                isToggledIndice ? draculaPurple : lilyPurple),
                        Text("Índice")
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                            onPressed: () => sendFingerCommand('Medio'),
                            icon: Icon(Icons.fingerprint_rounded),
                            iconSize: 40,
                            color: isToggledMedio ? draculaPurple : lilyPurple),
                        Text("Medio")
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => sendFingerCommand('Anular'),
                        icon: Icon(Icons.fingerprint_rounded),
                        iconSize: 40,
                        color: isToggledAnular ? draculaPurple : lilyPurple,
                      ),
                      Text("Anular")
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                          onPressed: () => sendFingerCommand('Menique'),
                          icon: Icon(Icons.fingerprint_rounded),
                          iconSize: 40,
                          color: isToggledMenique ? draculaPurple : lilyPurple),
                      Text("Meñique")
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text("Control total"),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: sendHandCommad,
                        icon: Icon(abierta
                            ? Icons.front_hand_outlined
                            : Icons.front_hand_rounded),
                        iconSize: 40,
                        color: abierta ? draculaPurple : darkPeriwinkle,
                      ),
                      Text(abierta ? "Abierta" : "Cerrada")
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendHandCommad() async {
    bool handState = false;
    // CASE FOR TOGGLE:
    setState(() {
      abierta = !abierta;
      handState = abierta;
    });

    try {
      User? newUser = FirebaseAuth.instance.currentUser;
      if (newUser != null) {
        await database
            .child('/MidasControl/' + newUser.uid.trim() + '/mano' + '/')
            .set({handState}); // Adjust accordingly for each finger
        print('Finger Command SENT: ${handState}');
      }
    } catch (error) {
      print('Error sending command: $error');
    }
  }

  Future<void> sendFingerCommand(String finger) async {
    bool fingerState = false;

    setState(() {
      switch (finger) {
        case "Pulgar":
          isToggledPulgar = !isToggledPulgar;
          fingerState = isToggledPulgar;
          print("Pulgar color changed.");
          print(isToggledPulgar);
          break;

        case "Indice":
          isToggledIndice = !isToggledIndice;
          fingerState = isToggledIndice;
          print("Indice color changed.");
          print(isToggledIndice);
          break;

        case "Medio":
          isToggledMedio = !isToggledMedio;
          fingerState = isToggledMedio;
          print("Medio color changed.");
          print(isToggledMedio);
          break;

        case "Anular":
          isToggledAnular = !isToggledAnular;
          fingerState = isToggledAnular;
          print("Anular color changed.");
          print(isToggledAnular);
          break;

        case "Menique":
          isToggledMenique = !isToggledMenique;
          fingerState = isToggledMenique;
          print("Menique color changed.");
          print(isToggledMenique);
          break;
      }
    });

    /*
    try {
      User? newUser = FirebaseAuth.instance.currentUser;
      if (newUser != null) {
        await database.child('/MidasControl/' + newUser.uid.trim() + '/').set(
            {finger: isToggledPulgar}); // Adjust accordingly for each finger
        print('Finger Command SENT');
      }
    } catch (error) {
      print('Error sending command: $error');
    }

    */

    // CASE FOR EACH FINGER:
    try {
      User? newUser = FirebaseAuth.instance.currentUser;
      if (newUser != null) {
        await database
            .child(
                '/MidasControl/' + newUser.uid.trim() + '/dedos' + '/' + finger)
            .set({fingerState}); // Adjust accordingly for each finger
        print('Finger Command SENT: ${finger}');
      }
    } catch (error) {
      print('Error sending command: $error');
    }
  }
}
