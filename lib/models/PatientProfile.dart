class PatientProfile {
  final String id; // UID del paciente
  final String name; // Nombre del paciente
  final int age; // edad del paciente
  final String gender; // género del paciente
  final DateTime diagnosisDate; // fecha de diagnóstico
  final String diagnosis; // tipo de diagnóstico
  final List<String>
      goal; // objetivo del tratamiento: adapatación, preparación, etc...
  final List<String> symptoms; // síntomas? inflamación, irritación,
  final double painLevel; // Escala del 0 a 10
  final String notes; // Observaciones: SMF (?)

  PatientProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.diagnosisDate,
    required this.diagnosis,
    required this.goal,
    required this.symptoms,
    required this.painLevel,
    required this.notes,
  });

  /// ********************* MÉTODOS DEL MODELO *****************************

  // Método para convertir a formato JSON --> Firebase Database
  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'diagnosisDate': diagnosisDate.toIso8601String(),
      'diagnosis': diagnosis,
      'goal': goal,
      'symptoms': symptoms,
      'painLevel': painLevel,
      'notes': notes
    };
  }

  // Método para convertir al modelo desde la database.
  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      diagnosisDate: DateTime.parse(json['diagnosisDate']),
      diagnosis: json['diagnosis'],
      goal: List<String>.from(json['goal']),
      symptoms: List<String>.from(json['symptoms']),
      painLevel: json['painLevel'],
      notes: json['notes'],
    );
  }
}
