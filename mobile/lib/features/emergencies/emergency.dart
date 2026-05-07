import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import '../../routes/app_routes.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _isSendingSOS = false;

  Future<Position?> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      _showMessage('Please enable location services');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        _showMessage('Location permission denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showMessage('Location permission permanently denied');
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>?> _findNearestHospital(Position userPos) async {
    final query = await FirebaseFirestore.instance
        .collection('services')
        .where('type', isEqualTo: 'Hospital')
        .where('isEmergencyAvailable', isEqualTo: true)
        .get();

    if (query.docs.isEmpty) return null;

    Map<String, dynamic>? nearest;
    double minDistance = double.infinity;

    for (final doc in query.docs) {
      final data = doc.data();
      final loc = data['location'] as GeoPoint?;

      if (loc == null) continue;

      final distance = Geolocator.distanceBetween(
        userPos.latitude,
        userPos.longitude,
        loc.latitude,
        loc.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = {
          ...data,
          'distanceKm': (distance / 1000).toStringAsFixed(1),
        };
      }
    }

    return nearest;
  }

  Future<void> _triggerSOS() async {
    setState(() {
      _isSendingSOS = true;
    });

    final position = await _getLocation();

    if (position == null) {
      setState(() {
        _isSendingSOS = false;
      });
      return;
    }

    final nearest = await _findNearestHospital(position);

    await FirebaseFirestore.instance.collection('sosAlerts').add({
      'location': GeoPoint(position.latitude, position.longitude),
      'timestamp': FieldValue.serverTimestamp(),
      'nearestHospital': nearest?['name'] ?? 'Unknown',
      'status': 'active',
    });

    setState(() {
      _isSendingSOS = false;
    });

    if (!mounted) return;

    _showSOSDialog(position, nearest);
  }

  void _showSOSDialog(Position pos, Map<String, dynamic>? hospital) {
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
                '📍 Your Location:',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lat: ${pos.latitude.toStringAsFixed(4)}\nLng: ${pos.longitude.toStringAsFixed(4)}',
                style: AppTypography.bodySmall.copyWith(
                  color: Neutral.neutral700,
                ),
              ),
              const SizedBox(height: 12),
              if (hospital != null) ...[
                Text(
                  '🏥 Nearest Hospital:',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${hospital['name']}\n${hospital['distanceKm']} km away',
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '📞 ${hospital['phoneNumber'] ?? 'No phone'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: VitalRed.vitalRed500,
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
                _callNumber(hospital?['phoneNumber'] ?? '140');
              },
              child: const Text('Call Hospital'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showMessage('Could not open phone app');
    }
  }

  Future<void> _sendEmergencySMS() async {
    final position = await _getLocation();

    if (position == null) return;

    final mapsLink =
        'https://maps.google.com/?q=${position.latitude},${position.longitude}';

    final body = Uri.encodeComponent(
      'EMERGENCY! I need help. My location: $mapsLink',
    );

    final uri = Uri.parse('sms:?body=$body');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showMessage('Could not open SMS');
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: VitalRed.vitalRed500,
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
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
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
              const Center(
                child: Text(
                  'Sending SOS... Getting location...',
                  style: TextStyle(
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