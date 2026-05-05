import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class BluetoothCard extends StatelessWidget {
  const BluetoothCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: VitalRed.vitalRed500,
            radius: 22,
            child: const Icon(Icons.bluetooth, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bluetooth is on", style: AppTypography.headingSmall),
                const SizedBox(height: 4),
                Text(
                  "Scanning for nearby devices...",
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (value) {},
            activeColor: VitalRed.vitalRed500,
          ),
        ],
      ),
    );
  }
}