import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/components/auth_button.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import '../../routes/app_routes.dart';
import '../../widgets/main_navigation.dart';

class WearablesScreen extends StatelessWidget {
  const WearablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral300,
      appBar: AppBar(
        backgroundColor: Neutral.neutral300,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Neutral.neutral900,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const MainNavigation(),
              ),
            );
          },
        ),
        title: Text(
          'Wearables',
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
            _connectCard(context),
            const SizedBox(height: 24),
            Text(
              'Supported Data',
              style: AppTypography.headingSmall.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _supportedDataCard(),
            const SizedBox(height: 16),
            _disclaimerCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _connectCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Neutral.neutral800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.watch,
                  color: Neutral.neutral100,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Wearable Connected',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Neutral.neutral900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connect a device to sync your\nhealth data automatically.',
                      style: AppTypography.bodySmall.copyWith(
                        color: Neutral.neutral700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AuthButton(
            text: 'Connect Wearable',
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.connectWearable,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _supportedDataCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _supportedDataRow('Heart Rate'),
          _supportedDataRow('Blood Pressure'),
          _supportedDataRow('Oxygen Level'),
        ],
      ),
    );
  }

  Widget _supportedDataRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Success.success500,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: AppTypography.bodyLarge.copyWith(
              color: Neutral.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _disclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Neutral.neutral400,
            ),
            child: const Icon(
              Icons.priority_high,
              color: Neutral.neutral100,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Wearable data is synced automatically and may not be always 100% accurate.\nAlways consult a healthcare professional for medical decisions.',
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}