import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import 'status_chip.dart';

class AdherenceItem extends StatelessWidget {
  final String title;
  final String time;
  final String status;

  const AdherenceItem({
    super.key,
    required this.title,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.bodyLarge),
            Text(
              time,
              style: AppTypography.bodySmall.copyWith(
                color: Neutral.neutral500,
              ),
            ),
          ],
        ),
        StatusChip(label: status),
      ],
    );
  }
}