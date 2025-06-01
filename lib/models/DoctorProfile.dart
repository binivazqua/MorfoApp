class DoctorProfile {
  String id;
  final String name;
  final String speciality;
  final String description;
  final String location;
  final String hospital;
  final String photoUrl;
  final String profileUrl;

  DoctorProfile({
    required this.id,
    required this.name,
    required this.speciality,
    required this.description,
    required this.location,
    required this.hospital,
    required this.photoUrl,
    required this.profileUrl,
  });

  // Convertir a JSON (por si se quisiera subir)
  Map<String, dynamic> toJSON() => {
        'id': id,
        'name': name,
        'speciality': speciality,
        'description': description,
        'location': location,
        'hospital': hospital,
        'pfpUrl': photoUrl,
        'profileUrl': profileUrl
      };

  // Crear desde JSON (al recibir de Firestore)
  factory DoctorProfile.fromJson(Map<String, dynamic> json) => DoctorProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      speciality: json['speciality'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      hospital: json['hospital'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      profileUrl: json['profileUrl'] ?? '');
}
