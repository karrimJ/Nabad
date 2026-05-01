import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';

class FrequencyToggle extends StatefulWidget {
  const FrequencyToggle({super.key});

  @override
  State<FrequencyToggle> createState() => _FrequencyToggleState();
}

class _FrequencyToggleState extends State<FrequencyToggle> {
  bool isOnce = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Neutral.neutral200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isOnce = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isOnce ? VitalRed.vitalRed500 : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Once",
                    style: AppTypography.bodyMedium.copyWith(
                      color: isOnce ? Colors.white : Neutral.neutral800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isOnce = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !isOnce ? VitalRed.vitalRed500 : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Daily",
                    style: AppTypography.bodyMedium.copyWith(
                      color: !isOnce ? Colors.white : Neutral.neutral800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}