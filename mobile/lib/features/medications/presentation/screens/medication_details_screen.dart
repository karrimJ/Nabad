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

            /// TOP CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Neutral.neutral100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [

                  /// ICON
                  const Icon(Icons.medication, size: 32, color: Colors.red),

                  const SizedBox(width: 12),

                  /// TEXT
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
                        const SizedBox(height: 6),
                        Text(
                          "In 2h 15m",
                          style: AppTypography.bodyMedium.copyWith(
                            color: VitalRed.vitalRed500,
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

            /// ADHERENCE TITLE
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Adherence",
                style: AppTypography.headingSmall,
              ),
            ),

            const SizedBox(height: 10),

            /// ADHERENCE CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Neutral.neutral100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: const [
                  AdherenceItem(
                    title: "Today",
                    time: "08:00 AM",
                    status: "UPCOMING",
                  ),
                  Divider(),
                  AdherenceItem(
                    title: "Yesterday",
                    time: "08:00 AM",
                    status: "TAKEN",
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// PRIMARY BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Mark as Taken"),
              ),
            ),

            const SizedBox(height: 12),

            /// SECONDARY BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Neutral.neutral300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Edit Medication",
                  style: AppTypography.bodyMedium.copyWith(
                    color: Neutral.neutral800,
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