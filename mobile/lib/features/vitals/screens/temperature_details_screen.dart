import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/components/auth_button.dart';
import 'add_manual_reading_screen.dart';
import 'package:mobile/routes/app_routes.dart';

class TemperatureDetailsScreen extends StatefulWidget {
  const TemperatureDetailsScreen({super.key});

  @override
  State<TemperatureDetailsScreen> createState() =>
      _TemperatureDetailsScreenState();
}

class _TemperatureDetailsScreenState extends State<TemperatureDetailsScreen> {
  int _selectedTab = 0; // 0 = Day, 1 = Week

  final List<double> _dayReadings = [36.6, 36.8, 36.9, 37.0, 37.1, 36.9];
  final List<String> _dayLabels = ['10:00', '14:00', '18:00', '22:00'];

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
          'Temperature',
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
            _summaryCard(),
            const SizedBox(height: 24),
            Text(
              'Temperature Trend',
              style: AppTypography.headingSmall.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _dayWeekToggle(),
            const SizedBox(height: 16),
            _chartCard(),
            const SizedBox(height: 16),
            _statusBanner(),
            const SizedBox(height: 16),
            _addReadingButton(),
            const SizedBox(height: 12),
            AuthButton(text: 'View History', onPressed: () {
              Navigator.pushNamed(context, AppRoutes.temperatureHistory);
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '36.8',
                style: AppTypography.headingLarge.copyWith(
                  color: Success.success500,
                  fontWeight: FontWeight.w800,
                  fontSize: 48,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '°C',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Neutral.neutral700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: Success.success500,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'STABLE',
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral100,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Normal range: 36.5 - 37.5 °C',
            style: AppTypography.bodyMedium.copyWith(
              color: Neutral.neutral800,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last updated: Today at 09:12',
            style: AppTypography.bodySmall.copyWith(color: Neutral.neutral600),
          ),
        ],
      ),
    );
  }

  Widget _dayWeekToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Neutral.neutral400, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_toggleButton('Day', 0), _toggleButton('Week', 1)],
      ),
    );
  }

  Widget _toggleButton(String text, int value) {
    final selected = _selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? VitalRed.vitalRed500 : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: AppTypography.bodyMedium.copyWith(
            color: selected ? Neutral.neutral100 : Neutral.neutral700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _chartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 180,
        child: CustomPaint(
          size: const Size(double.infinity, 180),
          painter: _LineChartPainter(
            readings: _dayReadings,
            xLabels: _dayLabels,
          ),
        ),
      ),
    );
  }

  Widget _statusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Success.success100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Success.success500,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your temperature is within the normal range.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Neutral.neutral900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'No action required',
                  style: AppTypography.bodySmall.copyWith(
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

  Widget _addReadingButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddReadingScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Neutral.neutral100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, color: VitalRed.vitalRed500, size: 22),
            const SizedBox(width: 12),
            Text(
              'Add Manual Reading',
              style: AppTypography.bodyLarge.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> readings;
  final List<String> xLabels;

  _LineChartPainter({required this.readings, required this.xLabels});

  @override
  void paint(Canvas canvas, Size size) {
    const minY = 36.0;
    const maxY = 37.5;
    const yLabels = [37.5, 37.0, 36.5, 36.0];

    const leftPad = 36.0;
    const rightPad = 12.0;
    const topPad = 8.0;
    const bottomPad = 28.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;

    final textStyle = TextStyle(
      color: Neutral.neutral600,
      fontSize: 11,
      fontFamily: 'Alexandria',
    );

    // Y-axis labels and gridlines
    final gridPaint = Paint()
      ..color = Neutral.neutral300
      ..strokeWidth = 1;

    for (final yVal in yLabels) {
      final ratio = (yVal - minY) / (maxY - minY);
      final y = topPad + chartHeight - (ratio * chartHeight);

      final tp = TextPainter(
        text: TextSpan(text: yVal.toString(), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        gridPaint,
      );
    }

    // Plot line
    final linePaint = Paint()
      ..color = VitalRed.vitalRed500
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()..color = VitalRed.vitalRed500;

    final path = Path();
    final points = <Offset>[];

    for (var i = 0; i < readings.length; i++) {
      final x = leftPad + (i / (readings.length - 1)) * chartWidth;
      final ratio = (readings[i] - minY) / (maxY - minY);
      final y = topPad + chartHeight - (ratio * chartHeight);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
    }

    // X-axis labels
    for (var i = 0; i < xLabels.length; i++) {
      final x = leftPad + (i / (xLabels.length - 1)) * chartWidth;
      final tp = TextPainter(
        text: TextSpan(text: xLabels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - bottomPad + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => false;
}
