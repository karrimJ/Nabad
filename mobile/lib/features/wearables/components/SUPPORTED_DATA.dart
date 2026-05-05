import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';

class SupportedDataSection extends StatelessWidget {
  const SupportedDataSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Supported Data"),
        const SizedBox(height: 12),
        Row(
          children: const [
            SupportedItem(icon: Icons.favorite, label: "Heart Rate"),
            SupportedItem(icon: Icons.air, label: "Oxygen Level"),
            SupportedItem(icon: Icons.monitor_heart, label: "Blood Pressure"),
          ],
        ),
      ],
    );
  }
}

class SupportedItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const SupportedItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: VitalRed.vitalRed500),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}