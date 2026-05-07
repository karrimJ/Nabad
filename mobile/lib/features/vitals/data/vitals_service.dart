import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'vital_reading_model.dart';

/// Thrown by [VitalsService] when a read/write fails.
class VitalsException implements Exception {
  final String message;
  const VitalsException(this.message);

  @override
  String toString() => 'VitalsException: $message';
}

/// Reads, writes, and deletes vital readings at `users/{uid}/vitals`.
///
/// All per-type list/stream queries rely on the composite index
/// `(type ASC, recordedAt DESC)` defined in `firestore.indexes.json`.
/// Without it, Firestore raises `failed-precondition`.
class VitalsService {
  VitalsService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _collectionRef {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('vitals');
  }

  // ── Streams ────────────────────────────────────────────────────────────

  /// Realtime stream of readings for [type], newest-first, optionally [limit].
  Stream<List<VitalReadingModel>> readingsStream({
    required String type,
    int? limit,
  }) {
    final col = _collectionRef;
    if (col == null) return Stream.value(const []);

    Query<Map<String, dynamic>> query = col
        .where('type', isEqualTo: type)
        .orderBy('recordedAt', descending: true);

    if (limit != null) query = query.limit(limit);

    return query.snapshots().map(
          (snap) => snap.docs
              .map(VitalReadingModel.fromFirestore)
              .toList(growable: false),
        );
  }

  /// Realtime stream of just the latest reading for [type], or null if none.
  Stream<VitalReadingModel?> latestReadingStream(String type) {
    return readingsStream(type: type, limit: 1)
        .map((list) => list.isEmpty ? null : list.first);
  }

  // ── One-shot reads ─────────────────────────────────────────────────────

  /// Returns readings for [type], newest-first.
  /// [since] / [until] bound the `recordedAt` range (inclusive).
  Future<List<VitalReadingModel>> getReadings({
    required String type,
    DateTime? since,
    DateTime? until,
    int? limit,
  }) async {
    final col = _collectionRef;
    if (col == null) return const [];

    try {
      Query<Map<String, dynamic>> query = col
          .where('type', isEqualTo: type)
          .orderBy('recordedAt', descending: true);

      if (since != null) {
        query = query.where(
          'recordedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(since),
        );
      }
      if (until != null) {
        query = query.where(
          'recordedAt',
          isLessThanOrEqualTo: Timestamp.fromDate(until),
        );
      }
      if (limit != null) query = query.limit(limit);

      final snap = await query.get();
      return snap.docs
          .map(VitalReadingModel.fromFirestore)
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw VitalsException(
        e.message ?? 'Failed to load vitals (${e.code}).',
      );
    } catch (e) {
      throw VitalsException('Failed to load vitals: $e');
    }
  }

  /// Latest reading for [type], or null if the user has no readings.
  Future<VitalReadingModel?> getLatestReading(String type) async {
    final list = await getReadings(type: type, limit: 1);
    return list.isEmpty ? null : list.first;
  }

  // ── Writes ─────────────────────────────────────────────────────────────

  /// Persists a manual reading. Used by AddReadingScreen.
  /// Throws [VitalsException] on failure.
  Future<void> addManualReading(VitalReadingModel reading) async {
    final col = _collectionRef;
    if (col == null) {
      throw const VitalsException(
        'You must be signed in to save a reading.',
      );
    }

    try {
      await col.add(reading.toMap());
    } on FirebaseException catch (e) {
      throw VitalsException(
        e.message ?? 'Failed to save reading (${e.code}).',
      );
    } catch (e) {
      throw VitalsException('Failed to save reading: $e');
    }
  }

  /// Deletes a single reading by id. Used by future detail/history actions.
  Future<void> deleteReading(String id) async {
    final col = _collectionRef;
    if (col == null) {
      throw const VitalsException(
        'You must be signed in to delete a reading.',
      );
    }

    try {
      await col.doc(id).delete();
    } on FirebaseException catch (e) {
      throw VitalsException(
        e.message ?? 'Failed to delete reading (${e.code}).',
      );
    } catch (e) {
      throw VitalsException('Failed to delete reading: $e');
    }
  }
}