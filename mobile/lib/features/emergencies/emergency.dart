import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/widgets/main_navigation.dart';

import '../../routes/app_routes.dart';
import 'data/emergency_service.dart';
import 'data/sos_alert_model.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final EmergencyService _emergencyService = EmergencyService();

  bool _isSendingSOS = false;
  String _sosStatusMessage = 'Getting location...';

  Future<void> _triggerSOS() async {
    if (_isSendingSOS) return;

    setState(() {
      _isSendingSOS = true;
      _sosStatusMessage = 'Getting location...';
    });

    try {
      final result = await _emergencyService.triggerSOS(
        onStatus: (message) {
          if (!mounted) return;

          setState(() {
            _sosStatusMessage = message;
          });
        },
      );

      if (!mounted) return;

      setState(() {
        _isSendingSOS = false;
      });

      _showMessage('SOS sent successfully', isSuccess: true);

      _showSOSDialog(
        result.position.latitude,
        result.position.longitude,
        result.nearestHospital,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSendingSOS = false;
      });

      _showMessage(_cleanError(error));
    }
  }

  Future<void> _callNumber(String number) async {
    try {
      await _emergencyService.callNumber(number);
    } catch (error) {
      _showMessage(_cleanError(error));
    }
  }

  Future<void> _sendEmergencySMS() async {
    try {
      await _emergencyService.sendEmergencySMS();
    } catch (error) {
      _showMessage(_cleanError(error));
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showSOSDialog(
    double latitude,
    double longitude,
    NearbyHospital? hospital,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Neutral.neutral100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber,
                color: VitalRed.vitalRed500,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'SOS Activated',
                style: AppTypography.headingSmall.copyWith(
                  color: VitalRed.vitalRed500,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Location:',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lat: ${latitude.toStringAsFixed(4)}\nLng: ${longitude.toStringAsFixed(4)}',
                style: AppTypography.bodySmall.copyWith(
                  color: Neutral.neutral700,
                ),
              ),
              const SizedBox(height: 12),
              if (hospital != null) ...[
                Text(
                  'Nearest Hospital:',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${hospital.name}\n${hospital.distanceKm.toStringAsFixed(1)} km away',
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hospital.phoneNumber ?? 'No phone',
                  style: AppTypography.bodySmall.copyWith(
                    color: VitalRed.vitalRed500,
                  ),
                ),
              ] else ...[
                Text(
                  'No emergency hospital found nearby.',
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral700,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: Text(
                'Close',
                style: AppTypography.bodyMedium.copyWith(
                  color: Neutral.neutral700,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VitalRed.vitalRed500,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _callNumber(hospital?.phoneNumber ?? '140');
              },
              child: const Text('Call Hospital'),
            ),
          ],
        );
      },
    );
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
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const MainNavigation(),
              ),
              (route) => false,
            );
          },
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
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Center(
              child: _sosButton(),
            ),
            const SizedBox(height: 16),
            if (_isSendingSOS)
              Center(
                child: Text(
                  'Sending SOS...\n$_sosStatusMessage',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: VitalRed.vitalRed500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 32),
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
      onTap: _isSendingSOS ? null : _triggerSOS,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              VitalRed.vitalRed500,
              Color(0xFFB71C1C),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: VitalRed.vitalRed500.withValues(alpha: 0.5),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: _isSendingSOS
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                )
              : Text(
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
          label: 'Call Red Cross (140)',
          onTap: () {
            _callNumber('140');
          },
        ),
        _divider(),
        _actionRow(
          icon: Icons.contact_emergency,
          label: 'Send Location to Contact',
          onTap: _sendEmergencySMS,
        ),
        _divider(),
        _actionRow(
          icon: Icons.group,
          label: 'Emergency Contacts',
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.emergencyContacts,
            );
          },
        ),
        _divider(),
        _actionRow(
          icon: Icons.local_hospital,
          label: 'Find Nearest Hospital',
          onTap: _triggerSOS,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: VitalRed.vitalRed500,
              size: 24,
            ),
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
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.medicalId,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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