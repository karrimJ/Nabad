import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_typography.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String assetPath;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.text,
    required this.assetPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Neutral.neutral100,
          side: BorderSide(color: Neutral.neutral300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetPath,
              height: 22,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}