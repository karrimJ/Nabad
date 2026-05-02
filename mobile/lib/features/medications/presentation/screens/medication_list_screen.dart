import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../services/medication_service.dart';
import '../../data/medication_model.dart';
import 'add_medication_screen.dart';
import 'medication_details_screen.dart';

class MedicationListScreen extends StatelessWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MedicationService();

    return Scaffold(
      backgroundColor: Neutral.neutral100,
      appBar: AppBar(
        backgroundColor: Neutral.neutral100,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: Text("Medication List",
            style: AppTypography.headingMedium
                .copyWith(color: Neutral.neutral900)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const AddMedicationScreen())),
              child: CircleAvatar(
                backgroundColor: VitalRed.vitalRed500,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<MedicationModel>>(
        stream: service.getMedications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final medications = snapshot.data ?? [];

          if (medications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication_outlined,
                      size: 64, color: Neutral.neutral400),
                  const SizedBox(height: 16),
                  Text("No medications yet",
                      style: AppTypography.bodyLarge
                          .copyWith(color: Neutral.neutral500)),
                  const SizedBox(height: 8),
                  Text("Tap + to add your first medication",
                      style: AppTypography.bodySmall
                          .copyWith(color: Neutral.neutral400)),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("All Medications", style: AppTypography.headingMedium),
                const SizedBox(height: 16),
                ...medications.map((med) => _medicationCard(context, med)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _medicationCard(BuildContext context, MedicationModel med) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MedicationDetailsScreen(medication: med))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Neutral.neutral100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
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
                  Text(med.medicationName,
                      style: AppTypography.headingSmall),
                  const SizedBox(height: 4),
                  Text(
                      '${med.dosage}${med.specificTimes.isNotEmpty ? ' - ${med.specificTimes}' : ''}',
                      style: AppTypography.bodySmall),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: VitalRed.vitalRed500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(med.frequency,
                  style: AppTypography.bodySmall
                      .copyWith(color: VitalRed.vitalRed500)),
            ),
          ],
        ),
      ),
    );
  }
}