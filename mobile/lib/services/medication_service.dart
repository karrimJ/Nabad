import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/medications/data/medication_model.dart';

class MedicationService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String? get _uid {
    return _auth.currentUser?.uid;
  }

  CollectionReference<Map<String, dynamic>>?
      get _medicationsRef {
    final uid = _uid;

    if (uid == null) return null;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('medications');
  }

  // CREATE
  Future<String?> addMedication(
    MedicationModel med,
  ) async {
    final ref = _medicationsRef;

    if (ref == null) return null;

    final doc = await ref.add(
      await med.toMap(),
    );

    return doc.id;
  }

  // READ ALL as realtime stream
  Stream<QuerySnapshot<Map<String, dynamic>>>
      getMedicationStream() {
    final ref = _medicationsRef;

    if (ref == null) {
      return const Stream.empty();
    }

    return ref
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots(
          includeMetadataChanges: true,
        );
  }

  // READ ALL as future list
  Future<List<MedicationModel>>
      getMedicationList() async {
    final ref = _medicationsRef;

    if (ref == null) return [];

    final snap = await ref
        .orderBy(
          'createdAt',
          descending: true,
        )
        .get();

    final medications =
        await Future.wait(
      snap.docs.map(
        (doc) =>
            MedicationModel.fromFirestore(
          doc,
        ),
      ),
    );

    return medications;
  }

  // READ ONE
  Future<MedicationModel?> getMedication(
    String id,
  ) async {
    final ref = _medicationsRef;

    if (ref == null) return null;

    final doc = await ref.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return MedicationModel.fromFirestore(
      doc,
    );
  }

  // UPDATE
  Future<void> updateMedication(
    String id,
    MedicationModel med,
  ) async {
    final ref = _medicationsRef;

    if (ref == null) return;

    await ref.doc(id).update(
          await med.toMap(),
        );
  }

  // DELETE
  Future<void> deleteMedication(
    String id,
  ) async {
    final ref = _medicationsRef;

    if (ref == null) return;

    await ref.doc(id).delete();
  }
}