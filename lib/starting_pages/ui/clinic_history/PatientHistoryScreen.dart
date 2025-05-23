import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:morflutter/design/constants.dart';
import 'package:intl/intl.dart';
import 'package:morflutter/models/PatientProfile.dart';

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
  final notes_controller = TextEditingController();
  double pain_value = 1.0;
  final List<String> symptoms_options = [
    'Dolor',
    'Fatiga',
    'Hormigueo',
    'Rigidez'
  ];

  final List<String> selected_symptoms = [];
  DateTime selected_date = DateTime.now();
  String? selected_gender;

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

  /* +++++++++++++++++++++ GENDER SELECTOR +++++++++++++++++++++++++++ */
  Widget genderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Género:',
          style: TextStyle(fontSize: 15),
        ),
        RadioListTile(
            value: "Femenino",
            title: Text(
              "Femenino",
              style: TextStyle(fontSize: 12),
            ),
            groupValue: selected_gender,
            onChanged: (value) {
              setState(() {
                selected_gender = value;
              });
            }),
        RadioListTile(
            value: "Masculino",
            title: Text(
              'Masculino',
              style: TextStyle(fontSize: 12),
            ),
            groupValue: selected_gender,
            onChanged: (value) {
              setState(() {
                selected_gender = value;
              });
            }),
        RadioListTile(
            value: "No binario",
            title: Text(
              'No binario',
              style: TextStyle(fontSize: 12),
            ),
            groupValue: selected_gender,
            onChanged: (value) {
              setState(() {
                selected_gender = value;
              });
            }),
        RadioListTile(
            value: "Prefiero no decirlo",
            title: Text(
              'Prefiero no decirlo',
              style: TextStyle(fontSize: 12),
            ),
            groupValue: selected_gender,
            onChanged: (value) {
              setState(() {
                selected_gender = value;
              });
            })
      ],
    );
  }

  /* ++++++++++++++++++++++ SYMPTOMS ++++++++++++++++++++++ */
  Widget symptomsChips() {
    return Wrap(
      spacing: 8,
      children: symptoms_options.map((symptom) {
        final isSelected =
            selected_symptoms.contains(symptom); // loop style check
        return (FilterChip(
            selectedColor: lilyPurple,
            label: Text(symptom),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                isSelected
                    ? selected_symptoms.remove(symptom) // ya está seleccionado
                    : selected_symptoms.add(symptom); // por seleccionar
              });
            }));
      }).toList(),
    );
  }

  /* ++++++++++++++++++++++ NOTES FIELD +++++++++++++++++++++++++++ */
  Widget notesSpace() {
    return (TextFormField(
      controller: notes_controller,
      maxLines: 5,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
    ));
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

  /* +++++++++++++++++++++++++++++++ SLIDER DE DOLOR +++++++++++++++++++++++++ */
  Widget painLevel() {
    return (Slider(
        value: pain_value,
        min: 0,
        max: 5,
        divisions: 5,
        label: pain_value.toString(),
        onChanged: (value) {
          setState(() {
            pain_value = value;
          });
        }));
  }

  /* ++++++++++++++++++++++++++++++ SEND INFO FUNC +++++++++++++++++++++++++++++ */

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
          child: Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                Text(
                  'Historial Clínico',
                  style: TextStyle(
                      fontSize: 20,
                      color: darkPeriwinkle,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledTextField('Nombre Completo',
                        controller: name_controller),
                    LabeledTextField('Edad', controller: age_controller),
                    SizedBox(
                      height: 5,
                    ),
                    genderSelector(),
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
                    ),
                    Text(
                      'Síntomas:',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    symptomsChips(),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Nivel de dolor:',
                      style: TextStyle(fontSize: 15),
                    ),
                    painLevel(),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Notas adicionales:',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    notesSpace()
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        /* final profile = PatientProfile(id: FirebaseAuth.instance.currentUser!.uid, name: name_controller.text, age: int.tryParse(age_controller.text) ?? 0, gender: selected_gender ?? '', diagnosisDate: selected_date, diagnosis: diagnosis_controller.text, goal: goal, symptoms: symptoms, painLevel: painLevel, notes: notes)*/
                      }
                    },
                    child: Text('Guardar'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
