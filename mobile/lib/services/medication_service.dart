import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/medications/data/medication_model.dart';

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
    final doc = await _medicationsRef.add(med.toMap());
    return doc.id;
  }

  // READ ALL (stream so UI auto-updates)
  Stream<List<MedicationModel>> getMedications() {
    return _medicationsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MedicationModel.fromFirestore(d)).toList());
  }

  // READ ONE
  Future<MedicationModel?> getMedication(String id) async {
    final doc = await _medicationsRef.doc(id).get();
    if (!doc.exists) return null;
    return MedicationModel.fromFirestore(doc);
  }

  // UPDATE
  Future<void> updateMedication(String id, Map<String, dynamic> data) async {
    await _medicationsRef.doc(id).update(data);
  }

  // DELETE
  Future<void> deleteMedication(String id) async {
    await _medicationsRef.doc(id).delete();
  }
}