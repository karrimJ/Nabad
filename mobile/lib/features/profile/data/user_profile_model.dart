import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain model for a Nabad user's profile, mapping to the `users/{uid}`
/// Firestore document.
///
/// Mirrors the architectural style of [MedicationModel]: a plain Dart class
/// with a [fromFirestore] factory and an explicit serialization method.
///
/// IMPORTANT: [toUpdateMap] returns ONLY the profile-editable fields plus an
/// `updatedAt` server timestamp. It must never include `uid`, `email`,
/// `createdAt`, the consent fields, or `linkedAccounts` — those are written
/// at registration / by other features and must not be overwritten by a
/// profile save.
class UserProfileModel {
  final String uid;
  final String email;
  final String displayName;
  final String? phone;
  final String? bio;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfileModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phone,
    this.bio,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Builds a model from a Firestore document snapshot.
  /// Tolerates missing fields (older accounts that registered before this
  /// schema existed) by falling back to safe defaults.
  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return UserProfileModel(
        uid: doc.id,
        email: '',
        displayName: '',
      );
    }

    return UserProfileModel(
      uid: doc.id,
      email: (data['email'] as String?) ?? '',
      displayName: (data['displayName'] as String?) ?? '',
      phone: data['phone'] as String?,
      bio: data['bio'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Partial map for a merge-update on the user doc.
  /// Excludes uid/email/createdAt/consent/linkedAccounts on purpose.
  Map<String, dynamic> toUpdateMap() {
    return {
      'displayName': displayName,
      'phone': phone,
      'bio': bio,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phone,
    String? bio,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}