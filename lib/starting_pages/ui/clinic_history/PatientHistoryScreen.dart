import 'package:flutter/material.dart';
import 'package:morflutter/design/constants.dart';
import 'package:intl/intl.dart';

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

  DateTime selected_date = DateTime.now();

  /* ++++++++++++++++++++++ TEXT FIELD WIDGET +++++++++++++++++++++++ */
  Widget LabeledTextField(
    String label, {
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ingresa $label'.toLowerCase();
          }
          return null;
        },
      ),
    );
  }

  /*+++++++++++++++++++++++ DATE PICKER +++++++++++++++++++++++++++ */
  Future<void> DatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        firstDate: DateTime(1990),
        initialDate: selected_date,
        lastDate: DateTime.now(),
        locale: Locale('es'));

    if (picked != null && picked != selected_date) {
      setState(() {
        selected_date = picked;
      });
    }
  }

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
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledTextField('Nombre Completo',
                        controller: name_controller),
                    LabeledTextField('Edad', controller: age_controller),
                    LabeledTextField('Diagnóstico',
                        controller: diagnosis_controller),
                    Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                            'Fecha de diagnóstico: ${DateFormat.yMd().format(selected_date)}'),
                        Spacer(),
                        TextButton(
                            onPressed: () => DatePicker(context),
                            child: Text('Cambiar'))
                      ],
                    )
                  ],
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
