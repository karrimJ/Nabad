import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/routes/app_routes.dart';

class HomeVitalsData {
  final int? heartRate;
  final int? oxygen;
  final double? temperature;
  final int? systolic;
  final int? diastolic;

  const HomeVitalsData({
    this.heartRate,
    this.oxygen,
    this.temperature,
    this.systolic,
    this.diastolic,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goTo(BuildContext context, String routeName) {
    Navigator.pop(context);
    Navigator.pushNamed(context, routeName);
  }

  Stream<HomeVitalsData> _liveVitalsStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value(const HomeVitalsData());
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('vitals')
        .orderBy('recordedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      int? heartRate;
      int? oxygen;
      double? temperature;
      int? systolic;
      int? diastolic;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final type = data['type'];

        if (type == 'heartRate' && heartRate == null) {
          heartRate = _toInt(data['value']);
        } else if (type == 'oxygen' && oxygen == null) {
          oxygen = _toInt(data['value']);
        } else if (type == 'temperature' && temperature == null) {
          temperature = _toDouble(data['value']);
        } else if (type == 'bloodPressure' &&
            systolic == null &&
            diastolic == null) {
          systolic = _toInt(data['systolic']);
          diastolic = _toInt(data['diastolic']);
        }

        if (heartRate != null &&
            oxygen != null &&
            temperature != null &&
            systolic != null &&
            diastolic != null) {
          break;
        }
      }

      return HomeVitalsData(
        heartRate: heartRate,
        oxygen: oxygen,
        temperature: temperature,
        systolic: systolic,
        diastolic: diastolic,
      );
    });
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString());
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  String _heartRateStatus(int? value) {
    if (value == null) return 'PENDING';
    if (value < 60) return 'LOW';
    if (value <= 100) return 'NORMAL';
    return 'HIGH';
  }

  String _oxygenStatus(int? value) {
    if (value == null) return 'PENDING';
    if (value >= 95) return 'NORMAL';
    if (value >= 90) return 'LOW';
    return 'CRITICAL';
  }

  String _temperatureStatus(double? value) {
    if (value == null) return 'PENDING';
    if (value >= 36.1 && value <= 37.5) return 'STABLE';
    if (value < 36.1) return 'LOW';
    return 'HIGH';
  }

  String _bloodPressureStatus(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) return 'PENDING';
    if (systolic < 120 && diastolic < 80) return 'NORMAL';
    if (systolic < 140 && diastolic < 90) return 'ELEVATED';
    return 'HIGH';
  }

  Color _statusColor(String status) {
    if (status == 'NORMAL' || status == 'STABLE') {
      return Success.success500;
    }

    if (status == 'PENDING') {
      return Neutral.neutral600;
    }

    if (status == 'LOW' || status == 'ELEVATED') {
      return const Color(0xFFE19831);
    }

    return VitalRed.vitalRed500;
  }

  Color _oxygenBackground(String status) {
    if (status == 'CRITICAL' || status == 'LOW') {
      return AccentRed.accentRed100;
    }

    return Neutral.neutral100;
  }

  Color _temperatureBackground(String status) {
    if (status == 'HIGH' || status == 'LOW') {
      return AccentRed.accentRed100;
    }

    return Neutral.neutral100;
  }

  Color _bloodPressureBackground(String status) {
    if (status == 'NORMAL') {
      return Neutral.neutral100;
    }

    if (status == 'PENDING') {
      return Neutral.neutral400;
    }

    return const Color(0xFFFFF1DC);
  }

  Color _bloodPressureValueColor(String status) {
    if (status == 'NORMAL') {
      return Success.success500;
    }

    if (status == 'PENDING') {
      return Neutral.neutral600;
    }

    if (status == 'HIGH' || status == 'ELEVATED') {
      return const Color(0xFFE19831);
    }

    return VitalRed.vitalRed500;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral300,
      drawer: _homeDrawer(context),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _greetingCard(),
                  const SizedBox(height: 24),
                  _sectionTitle("Today's Progress"),
                  const SizedBox(height: 16),
                  Center(child: _progressCircle(78)),
                  const SizedBox(height: 32),
                  _sectionTitle("Today's Vitals"),
                  const SizedBox(height: 12),

                  StreamBuilder<HomeVitalsData>(
                    stream: _liveVitalsStream(),
                    builder: (context, snapshot) {
                      final vitals = snapshot.data ?? const HomeVitalsData();

                      return Column(
                        children: [
                          _vitalsGrid(context, vitals),
                          const SizedBox(height: 12),
                          _bloodPressureCard(context, vitals),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  _sectionTitle("Today's Medications"),
                  const SizedBox(height: 12),
                  _medicationCard(context),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            Positioned(
              right: 16,
              top: 12,
              child: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Neutral.neutral900,
                      size: 28,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
            ),

            Positioned(
              right: 16,
              top: 360,
              child: _chatbotButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            CircleAvatar(
              radius: 36,
              backgroundColor: VitalRed.vitalRed500,
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 34,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Nabad',
              style: AppTypography.headingMedium.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 24),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                _goTo(context, AppRoutes.profile);
              },
            ),

            ExpansionTile(
              leading: const Icon(Icons.history),
              title: const Text('Vital History'),
              childrenPadding: const EdgeInsets.only(left: 24),
              children: [
                ListTile(
                  leading: const Icon(Icons.favorite, size: 20),
                  title: const Text('Heart Rate'),
                  onTap: () {
                    _goTo(context, AppRoutes.heartRateHistory);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.air, size: 20),
                  title: const Text('Oxygen Level'),
                  onTap: () {
                    _goTo(context, AppRoutes.oxygenHistory);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.thermostat, size: 20),
                  title: const Text('Temperature'),
                  onTap: () {
                    _goTo(context, AppRoutes.temperatureHistory);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bloodtype, size: 20),
                  title: const Text('Glucose Level'),
                  onTap: () {
                    _goTo(context, AppRoutes.glucoseHistory);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.monitor_heart, size: 20),
                  title: const Text('Blood Pressure'),
                  onTap: () {
                    _goTo(context, AppRoutes.bloodPressureHistory);
                  },
                ),
              ],
            ),

            ListTile(
              leading: const Icon(Icons.medication),
              title: const Text('Medications'),
              onTap: () {
                _goTo(context, AppRoutes.medications);
              },
            ),

            ListTile(
          leading: Image.asset(
  "assets/images/smartwatch.png",
  width: 28,
  height: 28,
),
              title: const Text('Wearables'),
              onTap: () {
                _goTo(context, AppRoutes.wearables);
              },
            ),

            ListTile(
              leading: const Icon(Icons.emergency, color: Colors.red),
              title: const Text(
                'Emergency',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                _goTo(context, AppRoutes.emergency);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _greetingCard() {
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName?.isNotEmpty == true
        ? user!.displayName!.split(' ').first
        : user?.email?.split('@').first ?? 'there';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi $name! 👋',
                  style: AppTypography.headingMedium.copyWith(
                    color: Neutral.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Here's your health summary for today.",
                  style: AppTypography.bodyMedium.copyWith(
                    color: Neutral.neutral700,
                  ),
                ),
              ],
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

  Widget _progressCircle(int percent) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: CustomPaint(
              painter: _ProgressPainter(percent / 100),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: AppTypography.headingLarge.copyWith(
                  color: VitalRed.vitalRed500,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'of goals reached',
                style: AppTypography.bodySmall.copyWith(
                  color: Neutral.neutral700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vitalsGrid(BuildContext context, HomeVitalsData vitals) {
    final heartStatus = _heartRateStatus(vitals.heartRate);
    final oxygenStatus = _oxygenStatus(vitals.oxygen);
    final temperatureStatus = _temperatureStatus(vitals.temperature);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.heartRate),
                child: _vitalCard(
                  image: 'assets/images/heart.png',
                  title: 'Heart Rate',
                  value: vitals.heartRate != null
                      ? '${vitals.heartRate} bpm'
                      : '--',
                  status: heartStatus,
                  statusColor: _statusColor(heartStatus),
                  background: Neutral.neutral100,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.oxygen),
                child: _vitalCard(
                  image: 'assets/images/lungs.png',
                  title: 'Oxygen Level',
                  value: vitals.oxygen != null ? '${vitals.oxygen}%' : '--',
                  status: oxygenStatus,
                  statusColor: _statusColor(oxygenStatus),
                  background: _oxygenBackground(oxygenStatus),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.temperature);
                },
                child: _vitalCard(
                  image: 'assets/images/temperature.png',
                  title: 'Temperature',
                  value: vitals.temperature != null
                      ? '${vitals.temperature!.toStringAsFixed(1)} °C'
                      : '--',
                  status: temperatureStatus,
                  statusColor: _statusColor(temperatureStatus),
                  background: _temperatureBackground(temperatureStatus),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.glucose),
                child: _vitalCard(
                  image: 'assets/images/glucose.png',
                  title: 'Glucose Level',
                  value: '--',
                  status: 'PENDING',
                  statusColor: Neutral.neutral600,
                  background: Neutral.neutral400,
                  valueColor: Neutral.neutral600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _vitalCard({
    required String image,
    required String title,
    required String value,
    required String status,
    required Color statusColor,
    required Color background,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            width: 26,
            height: 26,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: Neutral.neutral900,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: AppTypography.headingSmall.copyWith(
              color: valueColor ?? VitalRed.vitalRed500,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            status,
            style: AppTypography.bodySmall.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bloodPressureCard(BuildContext context, HomeVitalsData vitals) {
    final status = _bloodPressureStatus(vitals.systolic, vitals.diastolic);
    final bpColor = _bloodPressureValueColor(status);

    final value = vitals.systolic != null && vitals.diastolic != null
        ? '${vitals.systolic}/${vitals.diastolic} mmHg'
        : '--';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.bloodPressure);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _bloodPressureBackground(status),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Image.asset(
              'assets/images/bloodpressure.png',
              width: 32,
              height: 32,
            ),

            const SizedBox(height: 8),

            Text(
              'Blood Pressure',
              style: AppTypography.bodyLarge.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              value,
              style: AppTypography.headingMedium.copyWith(
                color: bpColor,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              status,
              style: AppTypography.bodySmall.copyWith(
                color: bpColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicationCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.medications);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Neutral.neutral100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/medication.png',
              width: 42,
              height: 42,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paracetamol',
                    style: AppTypography.bodyLarge.copyWith(
                      color: Neutral.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    'Next dose at 08:00 AM',
                    style: AppTypography.bodySmall.copyWith(
                      color: Neutral.neutral700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'In 2h 15m',
                    style: AppTypography.headingSmall.copyWith(
                      color: VitalRed.vitalRed500,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Success.success100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'TAKEN',
                      style: AppTypography.bodySmall.copyWith(
                        color: Success.success500,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatbotButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.assistant);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: VitalRed.vitalRed500,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/robot.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;

  _ProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    final bgPaint = Paint()
      ..color = Neutral.neutral400
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = VitalRed.vitalRed500
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}