import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_typography.dart';

class AuthFooter extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;

  const AuthFooter({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: Neutral.neutral600,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: AppTypography.bodySmall.copyWith(
              color: VitalRed.vitalRed500,
            ),
          ),
        ),
      ],
    );
  }
}