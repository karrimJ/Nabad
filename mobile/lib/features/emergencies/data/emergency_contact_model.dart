import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContactModel {
  const EmergencyContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.email,
    this.linkedUserId,
    this.fcmToken,
    this.isPrimary = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final String? email;
  final String? linkedUserId;
  final String? fcmToken;
  final bool isPrimary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory EmergencyContactModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return EmergencyContactModel(
      id: doc.id,
      name: _readString(data, 'name'),
      phoneNumber: _readString(data, 'phoneNumber'),
      relationship: _readString(data, 'relationship'),
      email: _readNullableString(data, 'email'),
      linkedUserId: _readNullableString(data, 'linkedUserId'),
      fcmToken: _readNullableString(data, 'fcmToken'),
      isPrimary: data['isPrimary'] == true,
      createdAt: _readDate(data, 'createdAt'),
      updatedAt: _readDate(data, 'updatedAt'),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'name': name.trim(),
      'phoneNumber': phoneNumber.trim(),
      'relationship': relationship.trim(),
      'email': _normalizeNullable(email),
      'linkedUserId': _normalizeNullable(linkedUserId),
      'fcmToken': _normalizeNullable(fcmToken),
      'isPrimary': isPrimary,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name.trim(),
      'phoneNumber': phoneNumber.trim(),
      'relationship': relationship.trim(),
      'email': _normalizeNullable(email),
      'linkedUserId': _normalizeNullable(linkedUserId),
      'fcmToken': _normalizeNullable(fcmToken),
      'isPrimary': isPrimary,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static String _readString(Map<String, dynamic> data, String key) {
    final value = data[key];

    if (value is String) {
      return value.trim();
    }

    return '';
  }

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];

    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return null;
  }

  static DateTime? _readDate(Map<String, dynamic> data, String key) {
    final value = data[key];

    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }

  static String? _normalizeNullable(String? value) {
    if (value == null) return null;

    final trimmed = value.trim();

    if (trimmed.isEmpty) return null;

    return trimmed;
  }
}