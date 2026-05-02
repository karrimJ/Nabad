import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../components/status_chip.dart';
import '../components/adherence_item.dart';

class MedicationDetailsScreen extends StatelessWidget {
  const MedicationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral100,

      appBar: AppBar(
        backgroundColor: Neutral.neutral100,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: Text(
          "Paracetamol",
          style: AppTypography.headingMedium.copyWith(
            color: Neutral.neutral900,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔴 TOP MEDICATION CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  /// ✅ PILL IMAGE (IMPORTANT)
                  Image.asset(
                    'assets/icons/pill.png',
                    width: 28,
                    height: 28,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Paracetamol", style: AppTypography.bodyLarge),

                        Text(
                          "500 mg - 08:00 AM",
                          style: AppTypography.bodySmall.copyWith(
                            color: Neutral.neutral500,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "In 2h 15m",
                          style: AppTypography.bodyMedium.copyWith(
                            color: VitalRed.vitalRed500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const StatusChip(label: "UPCOMING"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Adherence",
                style: AppTypography.headingSmall,
              ),
            ),

            const SizedBox(height: 10),

            /// 🔴 ADHERENCE CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [

                  const AdherenceItem(
                    title: "Today",
                    time: "08:00 AM",
                    status: "UPCOMING",
                  ),

                  /// ✅ LIGHT DIVIDER (FIXED)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 1,
                    color: Neutral.neutral200,
                  ),

                  const AdherenceItem(
                    title: "Yesterday",
                    time: "08:00 AM",
                    status: "TAKEN",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔴 PRIMARY BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: VitalRed.vitalRed500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Mark as Taken",
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// 🔴 SECONDARY BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Neutral.neutral300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Edit Medication",
                  style: AppTypography.bodyMedium.copyWith(
                    color: Neutral.neutral800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}