import 'package:flutter/material.dart';

import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import '../../widgets/main_navigation.dart';
import '../../routes/app_routes.dart';
import 'data/app_notification_model.dart';
import 'data/app_notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AppNotificationService _notificationService = AppNotificationService();

  String selectedFilter = 'All';
  bool _isClearing = false;

  List<AppNotificationModel> _filterNotifications(
    List<AppNotificationModel> notifications,
  ) {
    if (selectedFilter == 'All') return notifications;

    if (selectedFilter == 'Unread') {
      return notifications.where((notification) => !notification.isRead).toList();
    }

    return notifications.where((notification) {
      return notification.type.toLowerCase() == selectedFilter.toLowerCase();
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
              _filterOption('Unread'),
              _filterOption('Vitals'),
              _filterOption('Medication'),
              _filterOption('SOS'),
              _filterOption('General'),
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

  Future<void> _clearAll() async {
    if (_isClearing) return;

    setState(() {
      _isClearing = true;
    });

    try {
      await _notificationService.clearAll();

      if (!mounted) return;

      setState(() {
        _isClearing = false;
      });

      _showMessage('Notifications cleared', isSuccess: true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isClearing = false;
      });

      _showMessage(_cleanError(error));
    }
  }

  Future<void> _openNotification(AppNotificationModel notification) async {
    try {
      if (!notification.isRead) {
        await _notificationService.markAsRead(notification.id);
      }

      if (!mounted) return;

      final route = notification.route;

      if (route != null && route.isNotEmpty) {
        Navigator.pushNamed(context, route);
      }
    } catch (error) {
      _showMessage(_cleanError(error));
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showMessage(String msg, {bool isSuccess = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Success.success500 : VitalRed.vitalRed500,
      ),
    );
  }

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
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: Neutral.neutral900,
            ),
            onPressed: _openFilterSheet,
          ),
          IconButton(
            icon: _isClearing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: VitalRed.vitalRed500,
                    ),
                  )
                : const Icon(
                    Icons.delete_outline,
                    color: Neutral.neutral900,
                  ),
            onPressed: _isClearing ? null : _clearAll,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<AppNotificationModel>>(
        stream: _notificationService.watchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: VitalRed.vitalRed500,
              ),
            );
          }

          if (snapshot.hasError) {
            return _errorState(snapshot.error.toString());
          }

          final allNotifications = snapshot.data ?? [];
          final visibleNotifications = _filterNotifications(allNotifications);

          if (visibleNotifications.isEmpty) {
            return _emptyState();
          }

          return ListView(
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
              ...visibleNotifications.map(_notificationCard),
            ],
          );
        },
      ),
    );
  }

  Widget _notificationCard(AppNotificationModel notification) {
    final icon = _iconForType(notification.type);
    final isVital = notification.type.toLowerCase() == 'vitals';
    final isSos = notification.type.toLowerCase() == 'sos';

    return GestureDetector(
      onTap: () => _openNotification(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Neutral.neutral100 : AccentRed.accentRed100,
          borderRadius: BorderRadius.circular(14),
          border: notification.isRead
              ? null
              : Border.all(
                  color: VitalRed.vitalRed500.withValues(alpha: 0.18),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isVital || isSos
                    ? AccentRed.accentRed100
                    : Neutral.neutral300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isVital || isSos
                    ? VitalRed.vitalRed500
                    : Neutral.neutral800,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: Neutral.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Neutral.neutral700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification.createdAt),
                    style: AppTypography.bodySmall.copyWith(
                      color: Neutral.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: VitalRed.vitalRed500,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'vitals':
        return Icons.favorite;
      case 'medication':
        return Icons.medication;
      case 'sos':
        return Icons.warning_amber;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'Just now';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hr ago';
    if (difference.inDays == 1) return 'Yesterday';

    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _emptyState() {
    return Center(
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
              "We'll notify you about medication reminders,\nvital alerts, SOS alerts, and important health updates.",
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          error,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: VitalRed.vitalRed500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}