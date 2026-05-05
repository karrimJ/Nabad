import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/medications/presentation/screens/add_medication_screen.dart';
import 'features/medications/presentation/screens/medication_details_screen.dart';
import 'features/medications/presentation/screens/edit_medication_screen.dart';
import 'features/medications/presentation/screens/medication_list_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile/edit_profile_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/notifications/notifications1_screen.dart';
import 'features/medicalid/screens/medical_id_screen.dart';
import 'features/medicalid/screens/edit_medical_id_screen.dart';
import 'features/wearables/wearables.dart';
import 'features/vitals/screens/add_manual_reading_screen.dart';
import 'features/home/home_screen.dart';
import 'features/vitals/screens/temperature_details_screen.dart';
import 'features/vitals/screens/glucose_details_screen.dart';
import 'features/vitals/screens/heart_rate_history_screen.dart';
import 'features/vitals/screens/blood_pressure_details_screen.dart';
import 'features/vitals/screens/heart_rate_details_screen.dart';
import 'features/emergencies/emergency.dart';
import 'features/assistant/assistant.dart';
import 'theme/app_theme.dart';
import 'src/FCM/fcm_service.dart';
import 'features/wearables/connect_wearable_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
 

  await FCMService.initLocalNotifications();
  await FCMService.initialize();

  runApp(const NabdApp());
}

class NabdApp extends StatelessWidget {
  const NabdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nabd Thermocare',
      theme: AppTheme.lightTheme,
      home: const ConnectWearableScreen(),
    );
  }
}
