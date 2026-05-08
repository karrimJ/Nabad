import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'emergency_contact_model.dart';

class EmergencyContactService {
  EmergencyContactService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _contactsRef {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('emergencyContacts');
  }

  Stream<List<EmergencyContactModel>> watchEmergencyContacts() {
    return _contactsRef.snapshots().map((snapshot) {
      final contacts = snapshot.docs
          .map(EmergencyContactModel.fromFirestore)
          .toList();

      contacts.sort((a, b) {
        if (a.isPrimary != b.isPrimary) {
          return a.isPrimary ? -1 : 1;
        }

        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        return bDate.compareTo(aDate);
      });

      return contacts;
    });
  }

  Future<void> addEmergencyContact(EmergencyContactModel contact) async {
    _validateContact(contact);

    final linkedUserId = contact.linkedUserId?.trim();

    if (linkedUserId != null && linkedUserId.isNotEmpty) {
      await _contactsRef.doc(linkedUserId).set(
            contact.toCreateMap(),
            SetOptions(merge: true),
          );
      return;
    }

    await _contactsRef.add(contact.toCreateMap());
  }

  Future<void> updateEmergencyContact(EmergencyContactModel contact) async {
    if (contact.id.trim().isEmpty) {
      throw Exception('Contact ID is missing');
    }

    _validateContact(contact);

    await _contactsRef.doc(contact.id).update(contact.toUpdateMap());
  }

  Future<void> deleteEmergencyContact(String contactId) async {
    if (contactId.trim().isEmpty) {
      throw Exception('Contact ID is missing');
    }

    await _contactsRef.doc(contactId).delete();
  }

  Future<void> saveDefaultEmergencySettings() async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('emergencySettings')
        .doc('emergencySettings')
        .set(
      {
        'sosEnabled': true,
        'shareLocation': true,
        'notifyEmergencyContacts': true,
        'defaultEmergencyMessage':
            'Emergency alert from Nabad Thermocare. I may need help.',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  void _validateContact(EmergencyContactModel contact) {
    if (contact.name.trim().isEmpty) {
      throw Exception('Contact name is required');
    }

    if (contact.phoneNumber.trim().isEmpty) {
      throw Exception('Phone number is required');
    }

    if (contact.relationship.trim().isEmpty) {
      throw Exception('Relationship is required');
    }
  }
}