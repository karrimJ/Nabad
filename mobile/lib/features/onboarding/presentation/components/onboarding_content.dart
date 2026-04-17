import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import '../../../auth/presentation/components/auth_button.dart';

class OnboardingContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;
  final int currentIndex;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          /// TITLE
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.headingLarge.copyWith(
              color: Neutral.neutral900,
            ),
          ),

          const SizedBox(height: 12),

          /// SUBTITLE
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: Neutral.neutral600,
            ),
          ),

          const SizedBox(height: 16),

          /// DOTS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 4,
                width: currentIndex == index ? 20 : 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? VitalRed.vitalRed500
                      : Neutral.neutral300,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          /// BUTTON (CLOSE TO TEXT)
          AuthButton(
            text: buttonText,
            onPressed: onPressed,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}