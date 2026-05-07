import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_profile_model.dart';

/// Thrown by [UserProfileService] when a profile read/write fails.
class ProfileException implements Exception {
  final String message;
  const ProfileException(this.message);

  @override
  String toString() => 'ProfileException: $message';
}

/// Reads and updates the `users/{uid}` Firestore document for the current
/// authenticated user.
///
/// Mirrors the style of `lib/services/medication_service.dart`: a plain Dart
/// class wrapping a single Firebase API surface. Returns `null` from getters
/// when there is no signed-in user, rather than throwing — UI screens can
/// then show an empty state instead of crashing.
class UserProfileService {
  UserProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _userDocRef {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  /// Realtime stream of the current user's profile.
  /// Emits `null` if signed out or if the doc does not exist.
  Stream<UserProfileModel?> profileStream() {
    final ref = _userDocRef;
    if (ref == null) return Stream.value(null);

    return ref.snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserProfileModel.fromFirestore(snap);
    });
  }

  /// One-shot fetch of the current user's profile.
  /// Used by edit screens to populate controllers exactly once.
  Future<UserProfileModel?> getProfile() async {
    final ref = _userDocRef;
    if (ref == null) return null;

    try {
      final snap = await ref.get();
      if (!snap.exists) return null;
      return UserProfileModel.fromFirestore(snap);
    } on FirebaseException catch (e) {
      throw ProfileException(
        e.message ?? 'Failed to load profile (${e.code}).',
      );
    } catch (e) {
      throw ProfileException('Failed to load profile: $e');
    }
  }

  /// Partial update on the user doc. Uses `set(..., merge: true)` so it only
  /// touches the listed fields and never overwrites uid/email/createdAt/
  /// consent fields/linkedAccounts written by registration or by other
  /// features.
  Future<void> updateProfile({
    required String displayName,
    String? phone,
    String? bio,
    String? photoUrl,
  }) async {
    final ref = _userDocRef;
    if (ref == null) {
      throw const ProfileException(
        'You must be signed in to update your profile.',
      );
    }

    try {
      await ref.set({
        'displayName': displayName,
        'phone': phone,
        'bio': bio,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ProfileException(
        e.message ?? 'Failed to update profile (${e.code}).',
      );
    } catch (e) {
      throw ProfileException('Failed to update profile: $e');
    }
  }
}