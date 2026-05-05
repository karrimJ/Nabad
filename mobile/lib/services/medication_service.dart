import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/features/medications/data/medication_model.dart';

class MedicationService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _medicationsRef => _firestore
      .collection('users')
      .doc(_uid)
      .collection('medications');

  // CREATE
  Future<String> addMedication(MedicationModel med) async {
    final doc = await _medicationsRef.add(await med.toMap());
    return doc.id;
  }

  // READ ALL as a future list (fully decrypted)
  Future<List<MedicationModel>> getMedicationList() async {
    final snap = await _medicationsRef
        .orderBy('createdAt', descending: true)
        .get();
    return Future.wait(
      snap.docs.map((d) => MedicationModel.fromFirestore(d)),
    );
  }

  // READ ONE
  Future<MedicationModel?> getMedication(String id) async {
    final doc = await _medicationsRef.doc(id).get();
    if (!doc.exists) return null;
    return MedicationModel.fromFirestore(doc);
  }

  // UPDATE
  Future<void> updateMedication(String id, MedicationModel med) async {
    await _medicationsRef.doc(id).update(await med.toMap());
  }

  // DELETE
  Future<void> deleteMedication(String id) async {
    await _medicationsRef.doc(id).delete();
  }
}