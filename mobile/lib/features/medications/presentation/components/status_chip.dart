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
        bg = Success.success200;
        text = Success.success600;
        break;
      case "UPCOMING":
        bg = Neutral.neutral300;
        text = Neutral.neutral600;
        break;
      default:
        bg = Neutral.neutral300;
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