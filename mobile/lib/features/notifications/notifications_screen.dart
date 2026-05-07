import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import '../../widgets/main_navigation.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedFilter = 'All';

  final List<Map<String, String>> notifications = [
    {
      'title': 'High Heart Rate Alert',
      'message': 'Your heart rate was above the normal range.',
      'type': 'Vitals',
      'time': 'Today',
    },
    {
      'title': 'Medication Reminder',
      'message': 'Time to take your medication.',
      'type': 'Medication',
      'time': 'Today',
    },
    {
      'title': 'Low Oxygen Level',
      'message': 'Your oxygen level was below the normal range.',
      'type': 'Vitals',
      'time': 'Earlier',
    },
  ];

  List<Map<String, String>> get filteredNotifications {
    if (selectedFilter == 'All') {
      return notifications;
    }

    return notifications.where((notification) {
      return notification['type'] == selectedFilter ||
          notification['time'] == selectedFilter;
    }).toList();
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigation(),
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Neutral.neutral100,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter Notifications',
                style: AppTypography.headingSmall.copyWith(
                  color: Neutral.neutral900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _filterOption('All'),
              _filterOption('Today'),
              _filterOption('Vitals'),
              _filterOption('Medication'),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _filterOption(String filter) {
    final isSelected = selectedFilter == filter;

    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? VitalRed.vitalRed500 : Neutral.neutral600,
      ),
      title: Text(
        filter,
        style: AppTypography.bodyLarge.copyWith(
          color: Neutral.neutral900,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleNotifications = filteredNotifications;

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
          onPressed: _goToHome,
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
              icon: const Icon(
                Icons.filter_list,
                color: Neutral.neutral900,
              ),
              onPressed: _openFilterSheet,
            ),
          ),
        ],
      ),
      body: visibleNotifications.isEmpty
          ? Center(
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
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  selectedFilter == 'All'
                      ? 'All Notifications'
                      : '$selectedFilter Notifications',
                  style: AppTypography.headingSmall.copyWith(
                    color: Neutral.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ...visibleNotifications.map(
                  (notification) => _notificationCard(notification),
                ),
              ],
            ),
    );
  }

  Widget _notificationCard(Map<String, String> notification) {
    final bool isVital = notification['type'] == 'Vitals';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isVital ? AccentRed.accentRed100 : Neutral.neutral300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVital ? Icons.favorite : Icons.medication,
              color: isVital ? VitalRed.vitalRed500 : Neutral.neutral800,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'] ?? '',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Neutral.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'] ?? '',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Neutral.neutral700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification['time'] ?? '',
                  style: AppTypography.bodySmall.copyWith(
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