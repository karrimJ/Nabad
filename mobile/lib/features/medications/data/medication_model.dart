import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String id;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String specificTimes;
  final String startDate;
  final String endDate;
  final String instructions;
  final String medicineType;
  final String prescribedBy;
  final String color;
  final bool reminderEnabled;
  final DateTime createdAt;

  MedicationModel({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.specificTimes,
    required this.startDate,
    required this.endDate,
    required this.instructions,
    required this.medicineType,
    required this.prescribedBy,
    required this.color,
    required this.reminderEnabled,
    required this.createdAt,
  });

  factory MedicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicationModel(
      id: doc.id,
      medicationName: data['medicationName'] ?? '',
      dosage: data['dosage'] ?? '',
      frequency: data['frequency'] ?? '',
      specificTimes: data['specificTimes'] ?? '',
      startDate: data['startDate'] ?? '',
      endDate: data['endDate'] ?? '',
      instructions: data['instructions'] ?? '',
      medicineType: data['medicineType'] ?? '',
      prescribedBy: data['prescribedBy'] ?? '',
      color: data['color'] ?? '',
      reminderEnabled: data['reminderEnabled'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'specificTimes': specificTimes,
      'startDate': startDate,
      'endDate': endDate,
      'instructions': instructions,
      'medicineType': medicineType,
      'prescribedBy': prescribedBy,
      'color': color,
      'reminderEnabled': reminderEnabled,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}