import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../data/medication_model.dart';
import 'edit_medication_screen.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final MedicationModel medication;
  const MedicationDetailsScreen({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral100,
      appBar: AppBar(
        backgroundColor: Neutral.neutral100,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(medication.medicationName,
            style: AppTypography.headingMedium
                .copyWith(color: Neutral.neutral900)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Medication card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Neutral.neutral200,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.medication, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(medication.medicationName,
                            style: AppTypography.bodyLarge),
                        Text(
                            '${medication.dosage}${medication.specificTimes.isNotEmpty ? ' - ${medication.specificTimes}' : ''}',
                            style: AppTypography.bodySmall.copyWith(
                                color: Neutral.neutral500)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: VitalRed.vitalRed500.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(medication.frequency,
                        style: AppTypography.bodySmall
                            .copyWith(color: VitalRed.vitalRed500)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Details card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  _detailRow('Medicine Type', medication.medicineType),
                  _divider(),
                  _detailRow('Prescribed By', medication.prescribedBy),
                  _divider(),
                  _detailRow('Start Date', medication.startDate),
                  _divider(),
                  _detailRow('Instructions', medication.instructions),
                  _divider(),
                  _detailRow('Reminder',
                      medication.reminderEnabled ? 'Enabled' : 'Disabled'),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            EditMedicationScreen(medication: medication))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VitalRed.vitalRed500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Edit Medication',
                    style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.bodySmall
                  .copyWith(color: Neutral.neutral500)),
          Text(value.isEmpty ? '—' : value,
              style: AppTypography.bodyMedium
                  .copyWith(color: Neutral.neutral800)),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: Neutral.neutral200);
}