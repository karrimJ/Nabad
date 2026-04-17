import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class AuthInput extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;

  const AuthInput({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: AppTypography.bodyMedium.copyWith(
        color: Neutral.neutral800,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: Neutral.neutral500,
        ),
        prefixIcon: Icon(icon, color: Neutral.neutral500),

        filled: true,
        fillColor: Neutral.neutral100,

        contentPadding: const EdgeInsets.symmetric(vertical: 16),

        ///  IMPORTANT: set all borders SAME
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Neutral.neutral200,
            width: 1, // thinner = lighter feel
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Neutral.neutral200,
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Neutral.neutral200, // keep SAME for now
            width: 1,
          ),
        ),

        /// REMOVE DEFAULT FOCUS GLOW
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Neutral.neutral200,
            width: 1,
          ),
        ),
      ),
    );
  }
}