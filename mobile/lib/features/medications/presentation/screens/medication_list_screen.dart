import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../services/medication_service.dart';

import '../../data/medication_model.dart';

import 'add_medication_screen.dart';
import 'medication_details_screen.dart';
import '../../../../routes/app_routes.dart';
import '../../../../widgets/main_navigation.dart';

class MedicationListScreen extends StatelessWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MedicationService service = MedicationService();

    return Scaffold(
      backgroundColor: Neutral.neutral100,

      appBar: AppBar(
        backgroundColor: Neutral.neutral100,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),

          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigation()),
              (route) => false,
            );
          },
        ),

        title: Text(
          "Medication List",
          style: AppTypography.headingMedium.copyWith(
            color: Neutral.neutral900,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),

            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddMedicationScreen(),
                  ),
                );
              },

              child: CircleAvatar(
                backgroundColor: VitalRed.vitalRed500,

                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: service.getMedicationStream(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _emptyState();
          }

          final bool isFromCache = snapshot.data?.metadata.isFromCache ?? false;

          return FutureBuilder<List<MedicationModel>>(
            future: Future.wait(
              docs.map((doc) => MedicationModel.fromFirestore(doc)),
            ),

            builder: (context, medsSnapshot) {
              if (medsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (medsSnapshot.hasError) {
                return Center(child: Text('Error: ${medsSnapshot.error}'));
              }

              final medications = medsSnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    _offlineStatusBanner(isFromCache),

                    const SizedBox(height: 16),

                    Text("All Medications", style: AppTypography.headingMedium),

                    const SizedBox(height: 16),

                    ...medications.map(
                      (med) => _medicationCard(
                        context: context,
                        med: med,
                        isPending: false,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(Icons.medication_outlined, size: 64, color: Neutral.neutral400),

          const SizedBox(height: 16),

          Text(
            "No medications yet",
            style: AppTypography.bodyLarge.copyWith(color: Neutral.neutral500),
          ),

          const SizedBox(height: 8),

          Text(
            "Tap + to add your first medication",
            style: AppTypography.bodySmall.copyWith(color: Neutral.neutral400),
          ),
        ],
      ),
    );
  }

  Widget _offlineStatusBanner(bool isFromCache) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

      decoration: BoxDecoration(
        color: isFromCache
            ? VitalRed.vitalRed500.withOpacity(0.1)
            : Neutral.neutral200,

        borderRadius: BorderRadius.circular(10),
      ),

      child: Text(
        isFromCache
            ? 'Offline mode: showing saved medications'
            : 'Online: medications are synced',

        style: AppTypography.bodySmall.copyWith(
          color: isFromCache ? VitalRed.vitalRed500 : Neutral.neutral700,

          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _medicationCard({
    required BuildContext context,
    required MedicationModel med,
    required bool isPending,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedicationDetailsScreen(medication: med),
          ),
        );
      },

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
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,

              decoration: BoxDecoration(
                color: Neutral.neutral200,
                borderRadius: BorderRadius.circular(10),
              ),

              child: const Icon(Icons.medication, color: Colors.white),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(med.medicationName, style: AppTypography.headingSmall),

                  const SizedBox(height: 4),

                  Text(
                    med.specificTimes.isNotEmpty
                        ? '${med.dosage} - ${med.specificTimes}'
                        : med.dosage,

                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

              decoration: BoxDecoration(
                color: VitalRed.vitalRed500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),

              child: Text(
                med.frequency,

                style: AppTypography.bodySmall.copyWith(
                  color: VitalRed.vitalRed500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
