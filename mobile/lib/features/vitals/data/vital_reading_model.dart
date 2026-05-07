import 'package:cloud_firestore/cloud_firestore.dart';

/// Reading source — manual entry vs. wearable sync.
class VitalSource {
  VitalSource._();
  static const String manual = 'manual';
  static const String wearable = 'wearable';
}

/// Domain model for a single vital reading at
/// `users/{uid}/vitals/{autoId}`.
///
/// Same architectural pattern as [MedicationModel] and [MedicalInfoModel]:
/// plain Dart class with a [fromFirestore] factory and a [toMap] serializer.
///
/// Two named constructors enforce field shape:
///   • [VitalReadingModel.singleValue]   — heart rate, temperature, glucose, oxygen
///   • [VitalReadingModel.bloodPressure] — systolic + diastolic, value is null
///
/// Use [displayValue] to render the reading consistently
/// ("78", "36.8", "120/80").
class VitalReadingModel {
  final String id;
  final String type;        // VitalType.heartRate | bloodPressure | ...
  final double? value;      // single-value types
  final double? systolic;   // BP only
  final double? diastolic;  // BP only
  final String unit;
  final DateTime recordedAt;
  final String? notes;
  final String source;      // VitalSource.manual | VitalSource.wearable
  final DateTime createdAt;

  const VitalReadingModel._({
    required this.id,
    required this.type,
    required this.value,
    required this.systolic,
    required this.diastolic,
    required this.unit,
    required this.recordedAt,
    required this.notes,
    required this.source,
    required this.createdAt,
  });

  /// Builder for heart rate / temperature / glucose / oxygen.
  factory VitalReadingModel.singleValue({
    String id = '',
    required String type,
    required double value,
    required String unit,
    required DateTime recordedAt,
    String? notes,
    String source = VitalSource.manual,
    DateTime? createdAt,
  }) {
    return VitalReadingModel._(
      id: id,
      type: type,
      value: value,
      systolic: null,
      diastolic: null,
      unit: unit,
      recordedAt: recordedAt,
      notes: notes,
      source: source,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Builder for blood pressure (value is null; sys/dia carry the data).
  factory VitalReadingModel.bloodPressure({
    String id = '',
    required double systolic,
    required double diastolic,
    required DateTime recordedAt,
    String unit = 'mmHg',
    String? notes,
    String source = VitalSource.manual,
    DateTime? createdAt,
  }) {
    return VitalReadingModel._(
      id: id,
      type: 'bloodPressure',
      value: null,
      systolic: systolic,
      diastolic: diastolic,
      unit: unit,
      recordedAt: recordedAt,
      notes: notes,
      source: source,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory VitalReadingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return VitalReadingModel._(
      id: doc.id,
      type: (data['type'] as String?) ?? '',
      value: _asDouble(data['value']),
      systolic: _asDouble(data['systolic']),
      diastolic: _asDouble(data['diastolic']),
      unit: (data['unit'] as String?) ?? '',
      recordedAt: (data['recordedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      notes: data['notes'] as String?,
      source: (data['source'] as String?) ?? VitalSource.manual,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  bool get isBloodPressure => type == 'bloodPressure';

  /// Renders the reading exactly as the UI expects.
  /// "78"  for whole numbers, "36.8" for fractional, "120/80" for BP.
  String get displayValue {
    if (isBloodPressure) {
      return '${_fmt(systolic)}/${_fmt(diastolic)}';
    }
    return _fmt(value);
  }

  /// "78 bpm" / "120/80 mmHg" / "36.8 °C" / "98 %".
  String get displayValueWithUnit => '$displayValue $unit';

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'value': value,
      'systolic': systolic,
      'diastolic': diastolic,
      'unit': unit,
      'recordedAt': Timestamp.fromDate(recordedAt),
      'notes': notes,
      'source': source,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  static double? _asDouble(Object? raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  static String _fmt(double? v) {
    if (v == null) return '—';
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}