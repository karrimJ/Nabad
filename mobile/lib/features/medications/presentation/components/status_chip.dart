import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';

class StatusChip extends StatelessWidget {
  final String label;

  const StatusChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    switch (label) {
      case "TAKEN":
        bg = const Color(0xFFDFF5E3); // soft green
        text = const Color(0xFF2E7D32);
        break;

      case "UPCOMING":
        bg = Neutral.neutral200;
        text = Neutral.neutral600;
        break;

      default:
        bg = Neutral.neutral200;
        text = Neutral.neutral600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}