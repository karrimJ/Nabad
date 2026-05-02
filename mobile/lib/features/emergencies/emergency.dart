import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

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
          'Emergency',
          style: AppTypography.headingSmall.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Center(child: _sosButton()),
            const SizedBox(height: 48),
            Text(
              'Emergency Actions',
              style: AppTypography.headingSmall.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _actionsCard(),
            const SizedBox(height: 16),
            _viewMedicalIdCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sosButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [VitalRed.vitalRed500, Color(0xFFB71C1C)],
          ),
          boxShadow: [
            BoxShadow(
              color: VitalRed.vitalRed500.withOpacity(0.5),
              blurRadius: 40,
              spreadRadius: 8,
            ),
            BoxShadow(
              color: VitalRed.vitalRed500.withOpacity(0.3),
              blurRadius: 60,
              spreadRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'SOS',
            style: AppTypography.headingLarge.copyWith(
              color: Neutral.neutral100,
              fontWeight: FontWeight.w800,
              fontSize: 44,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _actionRow(
            icon: Icons.phone,
            label: 'Call Emergency Services',
            onTap: () {},
          ),
          _divider(),
          _actionRow(
            icon: Icons.contact_emergency,
            label: 'Notify Emergency Contact',
            onTap: () {},
          ),
          _divider(),
          _actionRow(
            icon: Icons.assignment,
            label: 'Share Last Vitals',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: VitalRed.vitalRed500, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: Neutral.neutral900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Neutral.neutral600,
              size: 20,
            ),
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

  Widget _viewMedicalIdCard() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Neutral.neutral100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: VitalRed.vitalRed500,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'View Medical ID',
              style: AppTypography.bodyLarge.copyWith(
                color: VitalRed.vitalRed500,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
