import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class MedicalIdScreen extends StatelessWidget {
  const MedicalIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral300,
      appBar: AppBar(
        backgroundColor: Neutral.neutral300,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Neutral.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Medical ID',
          style: AppTypography.headingSmall.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _userCard(),
            const SizedBox(height: 24),
            _sectionTitle('Medical Information'),
            const SizedBox(height: 12),
            _infoCard([
              _infoRow('Allergies', 'Penicillin'),
              _divider(),
              _infoRow('Chronic Conditions', 'Hypertension'),
              _divider(),
              _infoRow('Current Medications', 'Paracetamol, Metformin'),
            ]),
            const SizedBox(height: 24),
            _sectionTitle('Emergency Contact'),
            const SizedBox(height: 12),
            _infoCard([
              _infoRow('Name', 'Sarah'),
              _divider(),
              _infoRow('Relationship', 'Sister'),
              _divider(),
              _infoRow('Phone', '+961 71 015 648'),
            ]),
            const SizedBox(height: 24),
            Text(
              'This information can be accessed during emergencies to help healthcare providers respond quickly',
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _editButton(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _userCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Neutral.neutral400,
            ),
            child: const Icon(
              Icons.person,
              size: 44,
              color: Neutral.neutral600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Karim Jundi',
                  style: AppTypography.headingSmall.copyWith(
                    color: Neutral.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Age: 20 years',
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral700,
                  ),
                ),
                Text(
                  'Blood Type: AB +',
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: VitalRed.vitalRed500,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.medical_services,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.headingSmall.copyWith(
        color: Neutral.neutral900,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          style: AppTypography.bodyMedium.copyWith(
            color: Neutral.neutral800,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Neutral.neutral300,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _editButton(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Neutral.neutral100,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          'Edit Medical ID',
          style: AppTypography.bodyLarge.copyWith(
            color: VitalRed.vitalRed500,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}