import 'package:flutter/material.dart';
import 'package:morflutter/design/constants.dart';

class PatientHistoryScreen extends StatefulWidget {
  const PatientHistoryScreen({super.key});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final name_controller = TextEditingController();
  final age_controller = TextEditingController();
  final diagnosis_controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lilyPurple,
        title: Image(
            image: AssetImage(
              'lib/design/logos/rectangular_vino_trippypurplep.png',
            ),
            width: 120),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'Historial Clínico',
                  style: TextStyle(
                    fontSize: 20,
                    color: darkPeriwinkle,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextFormField(
                  controller: name_controller,
                  decoration: InputDecoration(labelText: 'Nombre Completo'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa un nombre';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: age_controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Edad'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa una edad';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: diagnosis_controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Diagnóstico'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa un diagnóstico';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print('Nombre: ${name_controller.text}');
                        print('Edad: ${age_controller.text}');
                        print('Goal: ${diagnosis_controller.text}');
                      }
                    },
                    child: Text('Guardar'))
              ],
            )),
      ),
    );
  }
}
