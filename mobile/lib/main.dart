import 'package:flutter/material.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

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
      home: const OnboardingScreen(),
    );
  }
}