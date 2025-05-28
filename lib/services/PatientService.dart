import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:morflutter/models/PatientProfile.dart';

class PatientService {
  static Future<void> savePatientProfile(PatientProfile profile) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw Exception('Usuario no autenticado');
    }
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(uid)
        .set(profile.toJSON());
  }

  /*+++++++++++++++++ LOAD PROFILE +++++++++++++++++++++ */
  static Future<PatientProfile> loadProfile(String uid) async {
    // encontrar colección en firestore
    final doc =
        await FirebaseFirestore.instance.collection('patients').doc(uid).get();

    return PatientProfile.fromJson(doc.data()!);
  }
}
