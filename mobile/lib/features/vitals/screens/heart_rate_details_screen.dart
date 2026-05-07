import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/components/auth_button.dart';
import 'add_manual_reading_screen.dart';

class HeartRateDetailsScreen extends StatelessWidget {
  const HeartRateDetailsScreen({super.key});

  static const _days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  static const _high = [115, 165, 95, 105, 130, 145, 170];
  static const _low = [70, 80, 78, 60, 95, 95, 85];

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
          'Heart Rate',
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
            const SizedBox(height: 20),
            Text(
              'Heart Rate Trend',
              style: AppTypography.headingSmall.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Weekly range 40 - 189 bpm',
              style: AppTypography.bodySmall.copyWith(
                color: Neutral.neutral600,
              ),
            ),
            const SizedBox(height: 16),
            _chartCard(),
            const SizedBox(height: 16),
            _statusBanner(),
            const SizedBox(height: 16),
            _addReadingButton(context),
            const SizedBox(height: 12),
            AuthButton(text: 'View History', onPressed: () {}),
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
                '78',
                style: AppTypography.headingLarge.copyWith(
                  color: Success.success500,
                  fontWeight: FontWeight.w800,
                  fontSize: 48,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'bpm',
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
              'NORMAL',
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral100,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Normal Range: 60 - 100 bpm',
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

  Widget _chartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: CustomPaint(
              size: const Size(double.infinity, 220),
              painter: _RangeBarPainter(days: _days, high: _high, low: _low),
            ),
          ),
          const SizedBox(height: 8),
          _readingRow('Today (14:00)', '125'),
          Divider(color: Neutral.neutral300, height: 1),
          _readingRow('Today (13:00)', '110'),
        ],
      ),
    );
  }

  Widget _readingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: Neutral.neutral800,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(
              color: Neutral.neutral900,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
            child: const Icon(Icons.favorite, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your heart rate is within the healthy range.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Neutral.neutral900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Keep maintaining an active lifestyle.',
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

  Widget _addReadingButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddReadingScreen(),
          ),
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

class _RangeBarPainter extends CustomPainter {
  final List<String> days;
  final List<int> high;
  final List<int> low;

  _RangeBarPainter({required this.days, required this.high, required this.low});

  @override
  void paint(Canvas canvas, Size size) {
    const minY = 40.0;
    const maxY = 190.0;

    const leftPad = 8.0;
    const rightPad = 8.0;
    const topPad = 12.0;
    const bottomPad = 32.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;

    final slot = chartWidth / days.length;
    const barWidth = 18.0;

    final separatorPaint = Paint()
      ..color = Neutral.neutral400
      ..strokeWidth = 1;

    for (var i = 1; i < days.length; i++) {
      final x = leftPad + slot * i;
      canvas.drawLine(
        Offset(x, topPad),
        Offset(x, topPad + chartHeight),
        separatorPaint,
      );
    }

    canvas.drawLine(
      Offset(leftPad, topPad),
      Offset(leftPad, topPad + chartHeight),
      separatorPaint,
    );

    canvas.drawLine(
      Offset(size.width - rightPad, topPad),
      Offset(size.width - rightPad, topPad + chartHeight),
      separatorPaint,
    );

    final textStyle = TextStyle(
      color: Neutral.neutral800,
      fontSize: 12,
      fontFamily: 'Alexandria',
      fontWeight: FontWeight.w500,
    );

    for (var i = 0; i < days.length; i++) {
      final cx = leftPad + slot * i + slot / 2;

      final highVal = high[i].toDouble();
      final lowVal = low[i].toDouble();

      final highRatio = (highVal - minY) / (maxY - minY);
      final lowRatio = (lowVal - minY) / (maxY - minY);

      final highY = topPad + chartHeight - (highRatio * chartHeight);
      final lowY = topPad + chartHeight - (lowRatio * chartHeight);

      final rect = Rect.fromLTWH(
        cx - barWidth / 2,
        highY,
        barWidth,
        lowY - highY,
      );

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE57373),
          VitalRed.vitalRed500,
          const Color(0xFF8B1818),
        ],
      );

      final paint = Paint()..shader = gradient.createShader(rect);

      final rrect = RRect.fromRectAndRadius(
        rect,
        const Radius.circular(10),
      );

      canvas.drawRRect(rrect, paint);

      final tp = TextPainter(
        text: TextSpan(text: days[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(cx - tp.width / 2, size.height - bottomPad + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RangeBarPainter oldDelegate) => false;
}