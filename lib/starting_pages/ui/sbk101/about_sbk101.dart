import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/design/constants.dart';
import 'package:morflutter/starting_pages/ui/sbk101/my_sbk101.dart';
import 'package:morflutter/starting_pages/ui/sbk101/sbk101_remoteControl.dart';

class AboutSbk101 extends StatelessWidget {
  void LogOut() {
    FirebaseAuth.instance.signOut();
  }

  const AboutSbk101({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sobre SBK-101',
                style: TextStyle(
                    fontFamily: 'Lausane650',
                    fontSize: 20,
                    color: draculaPurple),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child:
                    Image(image: AssetImage('lib/design/renders/sbk101.png')),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SBK101RemoteControl()));
                },
                child: Text(
                  'Conocer la mía',
                  style: TextStyle(color: morfoWhite),
                ),
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(darkPeriwinkle),
                    shadowColor: WidgetStatePropertyAll(draculaPurple)),
              ),

              /*
              ElevatedButton(
                  onPressed: () {
                    LogOut();
                  },
                  child: Text('log out'))*/
            ],
          ),
        ),
      ),
    );
  }
}
