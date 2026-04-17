import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final Widget content;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// IMAGE + GRADIENT
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),

              /// ✅ SOFT BOTTOM GRADIENT (LIKE FIGMA)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Neutral.neutral100,
                        Neutral.neutral100.withOpacity(0.9),
                        Neutral.neutral100.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.25, 0.6],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        /// CONTENT
        Expanded(
          flex: 4,
          child: content,
        ),
      ],
    );
  }
}