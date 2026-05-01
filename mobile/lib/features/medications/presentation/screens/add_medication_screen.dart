import '../components/input_field.dart';
import '../components/frequency_toggle.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';

class AddMedicationScreen extends StatelessWidget {
  const AddMedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral100,
      appBar: AppBar(
        backgroundColor: Neutral.neutral100,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: Text(
          "Add Medication",
          style: AppTypography.headingMedium.copyWith(
            color: Neutral.neutral900,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const InputField(
              label: "Medication Name",
              hint: "e.g Paracetamol",
            ),

            const SizedBox(height: 20),

            const InputField(
              label: "Dosage",
              hint: "500 mg",
            ),

            const SizedBox(height: 20),

            const InputField(
              label: "Time",
              hint: "08:00 AM",
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Frequency",
                style: AppTypography.bodyMedium,
              ),
            ),

            const SizedBox(height: 10),

            const FrequencyToggle(),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Save Medication"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}