import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goTo(BuildContext context, String routeName) {
    Navigator.pop(context);
    Navigator.pushNamed(context, routeName);
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

                  _vitalsGrid(context),

                  const SizedBox(height: 12),

                  _bloodPressureCard(context),

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
            Positioned(right: 16, top: 360, child: _chatbotButton(context)),
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
              child: const Icon(Icons.favorite, color: Colors.white, size: 34),
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
              leading: const Icon(Icons.watch),
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
                  'Hi Karim! 👋',

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

            child: CustomPaint(painter: _ProgressPainter(percent / 100)),
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

  Widget _vitalsGrid(BuildContext context) {
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
                  value: '78 bpm',
                  status: 'NORMAL',

                  statusColor: Success.success500,

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
                  value: '88%',
                  status: 'CRITICAL',

                  statusColor: VitalRed.vitalRed500,

                  background: AccentRed.accentRed100,
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
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.temperature),
                child: _vitalCard(
                  image: 'assets/images/temperature.png',

                  title: 'Temperature',
                  value: '36.8 °C',
                  status: 'STABLE',

                  statusColor: Success.success500,

                  background: Neutral.neutral100,
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
          Image.asset(image, width: 26, height: 26, fit: BoxFit.contain),

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

  Widget _bloodPressureCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.bloodPressure);
      },

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: const Color(0xFFFFF1DC),

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
              '142/88 mmHg',

              style: AppTypography.headingMedium.copyWith(
                color: const Color(0xFFE19831),
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'HIGH',

              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFFE19831),
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
            Image.asset('assets/images/medication.png', width: 42, height: 42),

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
