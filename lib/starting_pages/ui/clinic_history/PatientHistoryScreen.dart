import 'package:cloud_firestore/cloud_firestore.dart';
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

  final List<String> goals_options = [
    'Adaptación al dispositivo',
    'Aumentar resistencia al esfuerzo',
    'Gestión emocional durante el uso',
    'Superar un reto clínico'
  ];

  final List<String> selected_symptoms = [];
  final List<String> selected_goals = [];

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

  /* +++++++++++++++++++++++ GOAL SELECTOR ++++++++++++++++++++++ */
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

  /* ++++++++++++++++++++++ SYMPTOMS ++++++++++++++++++++++ */
  Widget goalsChips() {
    return Wrap(
      spacing: 8,
      children: goals_options.map((goal) {
        final isSelected = selected_goals.contains(goal); // loop style check
        return (FilterChip(
            selectedColor: lilyPurple,
            label: Text(goal),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                isSelected
                    ? selected_goals.remove(goal) // ya está seleccionado
                    : selected_goals.add(goal); // por seleccionar
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
  Future<void> submitPatientProfile() async {
    PatientProfile? profile;
    // si mandamos a validar el forms
    if (_formKey.currentState!.validate()) {
      // Instancia del modelo
      profile = PatientProfile(
          id: FirebaseAuth.instance.currentUser!.uid,
          name: name_controller.text.trim(),
          age: int.parse(age_controller.text.trim()),
          gender: selected_gender!,
          diagnosisDate: selected_date,
          diagnosis: diagnosis_controller.text.trim(),
          goal: selected_goals,
          symptoms: selected_symptoms,
          painLevel: pain_value,
          notes: notes_controller.text.trim());
    }

    // intentamos mandar el perfil
    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(profile!.id)
          .set(profile.toJSON());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Historial guardado correctamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error guardando historial: ${e}")),
      );
      print("${e}");
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
                    Text(
                      'Metas iniciales:',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    goalsChips(),
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
                      submitPatientProfile();
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
