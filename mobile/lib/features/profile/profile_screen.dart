import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import '../../routes/app_routes.dart';
import '../../widgets/main_navigation.dart';

import 'package:mobile/features/caregiver/caregiver_screen.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral300,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Neutral.neutral400,
                ),
                child: const Icon(
                  Icons.person,
                  size: 70,
                  color: Neutral.neutral600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nabad Developer',
                style: AppTypography.headingMedium.copyWith(
                  color: Neutral.neutral900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'developer@Nabad.com',
                style: AppTypography.bodyMedium.copyWith(
                  color: Neutral.neutral600,
                ),
              ),
              const SizedBox(height: 32),
              _menuItem(
                icon: Icons.person_outline,
                label: 'My Profile',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.editProfile);
                },
              ),
              const SizedBox(height: 12),
              _menuItem(
                icon: Icons.list_alt_outlined,
                label: 'My Vitals',
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 12),
              _menuItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),
              const SizedBox(height: 12),
              _menuItem(
                icon: Icons.family_restroom,
                label: 'Family & Caregiver',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaregiverScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _logoutItem(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Neutral.neutral100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Neutral.neutral800, size: 22),
            const SizedBox(width: 12),
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

  Widget _logoutItem({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Neutral.neutral100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.logout, color: VitalRed.vitalRed500, size: 22),
            const SizedBox(width: 12),
            Text(
              'Log Out',
              style: AppTypography.bodyLarge.copyWith(
                color: VitalRed.vitalRed500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}