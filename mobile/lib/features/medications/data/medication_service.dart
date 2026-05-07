import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'medication_model.dart';

class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _medicationsRef {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('medications');
  }

  // CREATE
  Future<String> addMedication(MedicationModel med) async {
    final doc = await _medicationsRef.add(await med.toMap());
    return doc.id;
  }

  // READ ALL as realtime stream for offline support
  Stream<QuerySnapshot<Map<String, dynamic>>> getMedicationStream() {
    return _medicationsRef
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  // READ ALL as a future list
  Future<List<MedicationModel>> getMedicationList() async {
    final snap = await _medicationsRef
        .orderBy('createdAt', descending: true)
        .get();

    final medications = await Future.wait(
      snap.docs.map((doc) => MedicationModel.fromFirestore(doc)),
    );

    return medications;
  }

  // READ ONE
  Future<MedicationModel?> getMedication(String id) async {
    final doc = await _medicationsRef.doc(id).get();

    if (!doc.exists) {
      return null;
    }

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