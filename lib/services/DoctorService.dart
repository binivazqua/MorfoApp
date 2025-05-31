import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morflutter/models/DoctorProfile.dart';

class DoctorService {
  static Future<List<DoctorProfile>> fetchDoctors() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('doctors').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return DoctorProfile.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  /*+++++++++++++++++ LOAD PROFILE +++++++++++++++++++++ */
  static Future<DoctorProfile> loadProfile(String doctorId) async {
    // encontrar colección en firestore
    final doc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .get();

    if (!doc.exists || doc.data() == null) {
      throw Exception("No se encontró el perfil del especialista.");
    }

    // SOLUCIÓN CHOLA
    final data = doc.data()!;

    return DoctorProfile.fromJson({...data, 'id': doc.id});
  }
}
