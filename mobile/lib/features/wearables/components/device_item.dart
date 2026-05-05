import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class DeviceItem extends StatelessWidget {
  const DeviceItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.watch, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Apple Watch Series 8",
              style: AppTypography.bodyMedium,
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: VitalRed.vitalRed500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "Connect",
              style: TextStyle(color: VitalRed.vitalRed500),
            ),
          ),
        ],
      ),
    );
  }
}