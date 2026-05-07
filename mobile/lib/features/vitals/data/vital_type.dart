/// Single source of truth for vital types across the app.
///
/// Owns three concerns:
/// 1. The canonical Firestore enum strings used in `users/{uid}/vitals.type`.
/// 2. The human display labels used in dropdowns and screen titles.
/// 3. The unit string for each type.
///
/// Keep this file in sync with the Firestore composite index in
/// `firestore.indexes.json` and with the `add_manual_reading_screen.dart`
/// dropdown options.
class VitalType {
  VitalType._();

  // ── Firestore enum strings (stored in `users/{uid}/vitals.type`) ──────
  static const String heartRate     = 'heartRate';
  static const String bloodPressure = 'bloodPressure';
  static const String temperature   = 'temperature';
  static const String glucose       = 'glucose';
  static const String oxygen        = 'oxygen';

  /// Order matches the dropdown order in AddReadingScreen.
  static const List<String> all = [
    heartRate,
    bloodPressure,
    temperature,
    glucose,
    oxygen,
  ];

  // ── Display labels (UI-facing) ────────────────────────────────────────
  static const String _lblHeartRate     = 'Heart Rate';
  static const String _lblBloodPressure = 'Blood Pressure';
  static const String _lblTemperature   = 'Temperature';
  static const String _lblGlucose       = 'Glucose';
  static const String _lblOxygen        = 'Oxygen Level';

  static const List<String> displayLabels = [
    _lblHeartRate,
    _lblBloodPressure,
    _lblTemperature,
    _lblGlucose,
    _lblOxygen,
  ];

  // ── Mappings ──────────────────────────────────────────────────────────
  static String fromDisplayLabel(String label) {
    switch (label) {
      case _lblHeartRate:     return heartRate;
      case _lblBloodPressure: return bloodPressure;
      case _lblTemperature:   return temperature;
      case _lblGlucose:       return glucose;
      case _lblOxygen:        return oxygen;
      default:
        throw ArgumentError('Unknown vital display label: $label');
    }
  }

  static String toDisplayLabel(String type) {
    switch (type) {
      case heartRate:     return _lblHeartRate;
      case bloodPressure: return _lblBloodPressure;
      case temperature:   return _lblTemperature;
      case glucose:       return _lblGlucose;
      case oxygen:        return _lblOxygen;
      default:
        throw ArgumentError('Unknown vital type: $type');
    }
  }

  static String unitFor(String type) {
    switch (type) {
      case heartRate:     return 'bpm';
      case bloodPressure: return 'mmHg';
      case temperature:   return '°C';
      case glucose:       return 'mg/dl';
      case oxygen:        return '%';
      default:
        throw ArgumentError('Unknown vital type: $type');
    }
  }
}