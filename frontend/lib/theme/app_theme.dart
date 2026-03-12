import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: Neutral.neutral100,

    fontFamily: AppTypography.fontFamily,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: VitalRed.vitalRed500,
      onPrimary: Colors.white,
      secondary: AccentRed.accentRed500,
      onSecondary: Colors.white,
      error: ErrorColors.error500,
      onError: Colors.white,
      background: Neutral.neutral100,
      onBackground: Neutral.neutral900,
      surface: Neutral.neutral200,
      onSurface: Neutral.neutral900,
    ),

    textTheme: const TextTheme(
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      headlineLarge: AppTypography.headingLarge,
      headlineMedium: AppTypography.headingMedium,
      headlineSmall: AppTypography.headingSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.buttonText,
      labelSmall: AppTypography.label,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: VitalRed.vitalRed500,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: VitalRed.vitalRed500,
        foregroundColor: Colors.white,
        textStyle: AppTypography.buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}