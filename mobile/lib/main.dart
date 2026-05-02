import 'package:flutter/material.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/medications/presentation/screens/medication_list_screen.dart'; 
import 'theme/app_theme.dart';
import 'features/medications/presentation/screens/add_medication_screen.dart';
import 'features/medications/presentation/screens/medication_details_screen.dart';
import 'features/medications/presentation/screens/edit_medication_screen.dart';
import 'features/profile/profile_screen.dart';

void main() {
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
      home: const ProfileScreen(),
    );
  }
}