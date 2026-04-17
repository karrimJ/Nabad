import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'features/auth/presentation/screens/register_screen.dart';



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
     home: RegisterScreen(),
    );
  }
}