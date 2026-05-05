import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/services/encryption_service.dart';

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

  static Future<MedicationModel> fromFirestore(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final enc = FieldEncryptionService();

    return MedicationModel(
      id: doc.id,
      medicationName: await enc.decrypt(data['medicationName']),
      dosage:         await enc.decrypt(data['dosage']),
      instructions:   await enc.decrypt(data['instructions']),
      prescribedBy:   await enc.decrypt(data['prescribedBy']),
      frequency:      data['frequency'] ?? '',
      specificTimes:  data['specificTimes'] ?? '',
      startDate:      data['startDate'] ?? '',
      endDate:        data['endDate'] ?? '',
      medicineType:   data['medicineType'] ?? '',
      color:          data['color'] ?? '',
      reminderEnabled: data['reminderEnabled'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Future<Map<String, dynamic>> toMap() async {
    final enc = FieldEncryptionService();

    return {
      'medicationName': await enc.encrypt(medicationName),
      'dosage':         await enc.encrypt(dosage),
      'instructions':   await enc.encrypt(instructions),
      'prescribedBy':   await enc.encrypt(prescribedBy),
      'frequency':      frequency,
      'specificTimes':  specificTimes,
      'startDate':      startDate,
      'endDate':        endDate,
      'medicineType':   medicineType,
      'color':          color,
      'reminderEnabled': reminderEnabled,
      'createdAt':      FieldValue.serverTimestamp(),
    };
  }
}