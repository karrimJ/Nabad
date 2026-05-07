import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'medical_info_model.dart';

/// Thrown by [MedicalInfoService] when a read/write fails.
class MedicalInfoException implements Exception {
  final String message;
  const MedicalInfoException(this.message);

  @override
  String toString() => 'MedicalInfoException: $message';
}

/// Reads, writes, and audits the Medical ID at
/// `users/{uid}/medicalInfo/profile`.
///
/// Audit-log writes (`auditLogs` top-level collection) are centralized here
/// with the EXACT same payload shape as the inline code that previously lived
/// in `medical_id_screen.dart`, so server-side log analytics keep working.
class MedicalInfoService {
  MedicalInfoService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _docRef {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('medicalInfo')
        .doc('profile');
  }

  /// Realtime stream of the current user's Medical ID.
  /// Emits [MedicalInfoModel.empty] when the doc does not yet exist.
  Stream<MedicalInfoModel> medicalInfoStream() {
    final ref = _docRef;
    if (ref == null) return Stream.value(MedicalInfoModel.empty());

    return ref.snapshots().map((snap) {
      if (!snap.exists) return MedicalInfoModel.empty();
      return MedicalInfoModel.fromFirestore(snap);
    });
  }

  /// One-shot fetch (used by the editor to populate controllers once).
  /// Returns [MedicalInfoModel.empty] if the doc does not exist.
  Future<MedicalInfoModel> getMedicalInfo() async {
    final ref = _docRef;
    if (ref == null) return MedicalInfoModel.empty();

    try {
      final snap = await ref.get();
      if (!snap.exists) return MedicalInfoModel.empty();
      return MedicalInfoModel.fromFirestore(snap);
    } on FirebaseException catch (e) {
      throw MedicalInfoException(
        e.message ?? 'Failed to load medical ID (${e.code}).',
      );
    } catch (e) {
      throw MedicalInfoException('Failed to load medical ID: $e');
    }
  }

  /// Persists the medical info using a merge-set so future fields added
  /// outside this screen (e.g. caregiver-share toggles) are not clobbered.
  /// Also writes an `updated_medical_id` audit log on success.
  Future<void> saveMedicalInfo(MedicalInfoModel info) async {
    final ref = _docRef;
    if (ref == null) {
      throw const MedicalInfoException(
        'You must be signed in to save your Medical ID.',
      );
    }

    try {
      await ref.set(info.toMap(), SetOptions(merge: true));
      // Best-effort audit log; never fail the save just because the audit
      // log write fails (e.g. rules deny it server-side).
      logAccess('updated_medical_id');
    } on FirebaseException catch (e) {
      throw MedicalInfoException(
        e.message ?? 'Failed to save Medical ID (${e.code}).',
      );
    } catch (e) {
      throw MedicalInfoException('Failed to save Medical ID: $e');
    }
  }

  /// Writes an entry to the top-level `auditLogs` collection.
  ///
  /// EXACT same payload shape as the inline write that previously lived in
  /// `medical_id_screen.dart` — preserved so server-side log analytics
  /// continue to work without changes.
  Future<void> logAccess(String action) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _firestore.collection('auditLogs').add({
        'userId': uid,
        'action': action,
        'resource': 'medicalInfo',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Audit log failures are intentionally swallowed — they should never
      // break user-facing flows. Pre-existing behavior.
    }
  }
}