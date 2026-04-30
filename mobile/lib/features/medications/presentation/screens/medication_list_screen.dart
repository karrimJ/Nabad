import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';

class MedicationListScreen extends StatelessWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral100,
      appBar: AppBar(
        backgroundColor: Neutral.neutral100,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: Text(
          "Medication List",
          style: AppTypography.headingMedium.copyWith(
            color: Neutral.neutral900,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: VitalRed.vitalRed500,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TODAY
            Text("Today", style: AppTypography.headingMedium),
            const SizedBox(height: 16),

            _medicationCard(
              title: "Paracetamol",
              subtitle: "500 mg - 08:00 AM",
              status: "TAKEN",
              statusColor: Success.success500,
              extra: "In 2h 15m",
            ),

            _medicationCard(
              title: "Liptor",
              subtitle: "500 mg - 08:00 AM",
              status: "MISSED",
              statusColor: ErrorColors.error500,
            ),

            _medicationCard(
              title: "Metformin",
              subtitle: "500 mg - 08:00 AM",
              status: "UPCOMING",
              statusColor: Neutral.neutral400,
              extra: "In 10h 15m",
            ),

            const SizedBox(height: 24),

            /// ALL MEDICATIONS
            Text("All Medications", style: AppTypography.headingMedium),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Neutral.neutral100,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _simpleItem(
                    "Paracetamol",
                    "Next dose 08:00 AM",
                    "TAKEN",
                    Success.success500,
                  ),

                  Divider(color: Neutral.neutral300),

                  _simpleItem(
                    "Liptor",
                    "Next dose 12:00 PM",
                    "MISSED",
                    ErrorColors.error500,
                  ),

                  Divider(color: Neutral.neutral300),

                  _simpleItem(
                    "Vitamin D",
                    "07:30 AM Tomorrow",
                    "UPCOMING",
                    Neutral.neutral400,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CARD
  Widget _medicationCard({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    String? extra,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// ICON
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Neutral.neutral200,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headingSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.bodySmall),

                if (extra != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    extra,
                    style: AppTypography.bodyMedium.copyWith(
                      color: VitalRed.vitalRed500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          /// STATUS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: AppTypography.bodySmall.copyWith(color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  /// SIMPLE LIST ITEM
  Widget _simpleItem(
    String title,
    String subtitle,
    String status,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Neutral.neutral200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headingSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.bodySmall),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: AppTypography.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
