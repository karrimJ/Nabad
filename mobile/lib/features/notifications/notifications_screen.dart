import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
          'Notifications',
          style: AppTypography.headingSmall.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Neutral.neutral900),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications,
                size: 110,
                color: Neutral.neutral500,
              ),
              const SizedBox(height: 24),
              Text(
                'No Notifications Yet',
                style: AppTypography.headingMedium.copyWith(
                  color: Neutral.neutral900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We'll notify you about medication reminders,\nvital alerts, and important health updates.",
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: Neutral.neutral600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}