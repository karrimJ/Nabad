import 'package:flutter/material.dart';

import '../features/medications/data/medication_model.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/medications/presentation/screens/medication_list_screen.dart';
import '../features/medications/presentation/screens/add_medication_screen.dart';
import '../features/medications/presentation/screens/medication_details_screen.dart';
import '../features/medications/presentation/screens/edit_medication_screen.dart';
import '../features/medicalid/screens/medical_id_screen.dart';
import '../features/medicalid/screens/edit_medical_id_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/notifications/notifications1_screen.dart';
import '../features/wearables/wearables.dart';
import '../features/wearables/connect_wearable_screen.dart';
import '../features/vitals/screens/heart_rate_details_screen.dart';
import '../features/vitals/screens/heart_rate_history_screen.dart';
import '../features/vitals/screens/blood_pressure_details_screen.dart';
import '../features/vitals/screens/temperature_details_screen.dart';
import '../features/vitals/screens/glucose_details_screen.dart';
import '../features/vitals/screens/Oxygen_level_screen.dart';
import '../features/vitals/screens/add_manual_reading_screen.dart';
import '../features/vitals/screens/oxygen_history_screen.dart';
import '../features/vitals/screens/temperature_history_screen.dart';
import '../features/vitals/screens/glucose_history_screen.dart';
import '../features/vitals/screens/blood_pressure_history_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/emergencies/emergency.dart';
import '../features/emergencies/emergency_contacts_screen.dart';
import '../features/assistant/assistant.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';

  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  static const String medications = '/medications';
  static const String addMedication = '/medications/add';
  static const String medicationDetails = '/medications/details';
  static const String editMedication = '/medications/edit';

  static const String medicalId = '/medical-id';
  static const String editMedicalId = '/medical-id/edit';

  static const String notifications = '/notifications';
  static const String notificationsList = '/notifications/list';

  static const String wearables = '/wearables';
  static const String connectWearable = '/wearables/connect';

  static const String heartRate = '/vitals/heart-rate';
  static const String heartRateHistory = '/vitals/heart-rate/history';

  static const String bloodPressure = '/vitals/blood-pressure';
  static const String bloodPressureHistory = '/vitals/blood-pressure/history';

  static const String temperature = '/vitals/temperature';
  static const String temperatureHistory = '/vitals/temperature/history';

  static const String oxygen = '/vitals/oxygen';
  static const String oxygenHistory = '/vitals/oxygen/history';

  static const String glucose = '/vitals/glucose';
  static const String glucoseHistory = '/vitals/glucose/history';

  static const String addReading = '/vitals/add-reading';

  static const String emergency = '/emergency';
  static const String emergencyContacts = '/emergency/contacts';

  static const String assistant = '/assistant';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => RegisterScreen(),

      profile: (context) => const ProfileScreen(),
      editProfile: (context) => const EditProfileScreen(),

      medications: (context) => const MedicationListScreen(),
      addMedication: (context) => const AddMedicationScreen(),

      medicalId: (context) => const MedicalIdScreen(),
      editMedicalId: (context) => const EditMedicalIdScreen(),

      notifications: (context) => const NotificationsScreen(),
      notificationsList: (context) => const NotificationsListScreen(),

      wearables: (context) => const WearablesScreen(),
      connectWearable: (context) => const ConnectWearableScreen(),

      heartRate: (context) => const HeartRateDetailsScreen(),
      heartRateHistory: (context) => const HeartRateHistoryScreen(),

      bloodPressure: (context) => const BloodPressureDetailsScreen(),
      bloodPressureHistory: (context) => const BloodPressureHistoryScreen(),

      temperature: (context) => const TemperatureDetailsScreen(),
      temperatureHistory: (context) => const TemperatureHistoryScreen(),

      oxygen: (context) => const OxygenLevelScreen(),
      oxygenHistory: (context) => const OxygenHistoryScreen(),

      glucose: (context) => const GlucoseDetailsScreen(),
      glucoseHistory: (context) => const GlucoseHistoryScreen(),

      addReading: (context) => const AddReadingScreen(),

      emergency: (context) => const EmergencyScreen(),
      emergencyContacts: (context) => const EmergencyContactsScreen(),

      assistant: (context) => const NabadAssistantScreen(),
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case medicationDetails:
        final medication = settings.arguments as MedicationModel;

        return MaterialPageRoute(
          builder: (_) => MedicationDetailsScreen(
            medication: medication,
          ),
        );

      case editMedication:
        final medication = settings.arguments as MedicationModel;

        return MaterialPageRoute(
          builder: (_) => EditMedicationScreen(
            medication: medication,
          ),
        );

      default:
        return null;
    }
  }
}