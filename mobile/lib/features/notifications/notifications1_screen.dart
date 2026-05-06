import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class NotificationsListScreen extends StatelessWidget {
  const NotificationsListScreen({super.key});

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

          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          'Notifications',

          style:
              AppTypography.headingSmall.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),

        titleSpacing: 0,

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),

            child: IconButton(
              icon: const Icon(
                Icons.menu,
                color: Neutral.neutral900,
              ),

              onPressed: () {},
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),

        child: Column(
          children: [
            _notificationCard(
              image:
                  'assets/images/medication.png',

              title: 'Medication Reminder',
              subtitle: 'Take Paracetamol',
              time: '2 min ago',

              backgroundColor:
                  Neutral.neutral100,
            ),

            const SizedBox(height: 12),

            _notificationCard(
              image: 'assets/images/heart.png',

              title: 'Heart Rate Update',
              subtitle:
                  'Reading saved successfully',

              time: 'Today 08:30',

              backgroundColor:
                  Success.success100,
            ),

            const SizedBox(height: 12),

            _notificationCard(
              image:
                  'assets/images/bloodpressure.png',

              title: 'Blood Pressure Alert',
              subtitle:
                  'Your reading is above normal',

              time: 'Yesterday',

              backgroundColor:
                  AccentRed.accentRed100,

              borderColor:
                  VitalRed.vitalRed500
                      .withOpacity(0.25),
            ),

            const SizedBox(height: 26),

            GestureDetector(
              onTap: () {},

              child: Text(
                'Clear All',

                style:
                    AppTypography.bodyLarge
                        .copyWith(
                  color: VitalRed.vitalRed500,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationCard({
    required String image,
    required String title,
    required String subtitle,
    required String time,
    required Color backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      decoration: BoxDecoration(
        color: backgroundColor,

        borderRadius: BorderRadius.circular(16),

        border:
            borderColor != null
                ? Border.all(
                  color: borderColor,
                  width: 1,
                )
                : null,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,

        children: [
          Image.asset(
            image,
            width: 34,
            height: 34,
            fit: BoxFit.contain,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style:
                      AppTypography.bodyLarge
                          .copyWith(
                    color: Neutral.neutral900,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,

                  style:
                      AppTypography.bodyMedium
                          .copyWith(
                    color: Neutral.neutral700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  time,

                  style:
                      AppTypography.bodySmall
                          .copyWith(
                    color: Neutral.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}