import 'package:cloud_firestore/cloud_firestore.dart';

/// Nested emergency-contact value object inside the medical-info doc.
class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;

  const EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
  });

  const EmergencyContact.empty()
      : name = '',
        relationship = '',
        phone = '';

  factory EmergencyContact.fromMap(Map<String, dynamic> data) {
    return EmergencyContact(
      name: (data['name'] as String?) ?? '',
      relationship: (data['relationship'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'phone': phone,
    };
  }

  bool get isEmpty => name.isEmpty && relationship.isEmpty && phone.isEmpty;
}

/// Domain model for a Nabad user's Medical ID, mapping to the
/// `users/{uid}/medicalInfo/profile` Firestore document.
///
/// Same architectural pattern as [MedicationModel]: plain Dart class with a
/// [fromFirestore] factory and a [toMap] serializer. We use a single fixed
/// document id (`profile`) per user.
///
/// All fields are stored plain (matching the schema approved with the user).
/// To switch to AES-encrypted fields like [MedicationModel], wrap the
/// sensitive getters in [FieldEncryptionService].
class MedicalInfoModel {
  final String fullName;
  final String bloodType;
  final DateTime? dateOfBirth;
  final String allergies;
  final String chronicConditions;
  final String currentMedications;
  final EmergencyContact emergencyContact;
  final DateTime? updatedAt;

  const MedicalInfoModel({
    required this.fullName,
    required this.bloodType,
    this.dateOfBirth,
    required this.allergies,
    required this.chronicConditions,
    required this.currentMedications,
    required this.emergencyContact,
    this.updatedAt,
  });

  /// Empty initial value, used when the doc does not yet exist.
  factory MedicalInfoModel.empty() => const MedicalInfoModel(
        fullName: '',
        bloodType: '',
        allergies: '',
        chronicConditions: '',
        currentMedications: '',
        emergencyContact: EmergencyContact.empty(),
      );

  factory MedicalInfoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return MedicalInfoModel.empty();

    final ec = data['emergencyContact'] as Map<String, dynamic>?;

    return MedicalInfoModel(
      fullName: (data['fullName'] as String?) ?? '',
      bloodType: (data['bloodType'] as String?) ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      allergies: (data['allergies'] as String?) ?? '',
      chronicConditions: (data['chronicConditions'] as String?) ?? '',
      currentMedications: (data['currentMedications'] as String?) ?? '',
      emergencyContact: ec != null
          ? EmergencyContact.fromMap(ec)
          : const EmergencyContact.empty(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// True when no field has been filled in yet.
  bool get isEmpty =>
      fullName.isEmpty &&
      bloodType.isEmpty &&
      dateOfBirth == null &&
      allergies.isEmpty &&
      chronicConditions.isEmpty &&
      currentMedications.isEmpty &&
      emergencyContact.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'bloodType': bloodType,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'currentMedications': currentMedications,
      'emergencyContact': emergencyContact.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  MedicalInfoModel copyWith({
    String? fullName,
    String? bloodType,
    DateTime? dateOfBirth,
    String? allergies,
    String? chronicConditions,
    String? currentMedications,
    EmergencyContact? emergencyContact,
    DateTime? updatedAt,
  }) {
    return MedicalInfoModel(
      fullName: fullName ?? this.fullName,
      bloodType: bloodType ?? this.bloodType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}