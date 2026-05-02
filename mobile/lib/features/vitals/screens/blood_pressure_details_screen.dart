import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/components/auth_button.dart';

class BloodPressureDetailsScreen extends StatelessWidget {
  const BloodPressureDetailsScreen({super.key});

  static const _days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  static const _systolic = [120, 142, 130, 110, 122, 138, 145];
  static const _diastolic = [78, 95, 85, 72, 80, 88, 90];

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
          'Blood Pressure',
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
              'Blood Pressure Trend',
              style: AppTypography.headingSmall.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Weekly range <120 / <80 mmh',
              style: AppTypography.bodySmall.copyWith(
                color: Neutral.neutral600,
              ),
            ),
            const SizedBox(height: 16),
            _chartCard(),
            const SizedBox(height: 16),
            _statusBanner(),
            const SizedBox(height: 16),
            _addReadingButton(),
            const SizedBox(height: 12),
            AuthButton(
              text: 'View History',
              onPressed: () {},
            ),
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
                '142/88',
                style: AppTypography.headingLarge.copyWith(
                  color: VitalRed.vitalRed500,
                  fontWeight: FontWeight.w800,
                  fontSize: 42,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'mmHg',
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
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: VitalRed.vitalRed500,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'HIGH',
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral100,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Normal Range: <120 / <80 mmh',
            style: AppTypography.bodyMedium.copyWith(
              color: Neutral.neutral800,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last updated: Today at 09:12',
            style: AppTypography.bodySmall.copyWith(
              color: Neutral.neutral600,
            ),
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
              painter: _BarChartPainter(
                days: _days,
                systolic: _systolic,
                diastolic: _diastolic,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _readingRow('Today (14:00)', '142', '88'),
          Divider(color: Neutral.neutral300, height: 1),
          _readingRow('Today (13:00)', '138', '85'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(VitalRed.vitalRed500, 'Systolic'),
              const SizedBox(width: 24),
              _legend(const Color(0xFFFF6B5A), 'Diastolic'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _readingRow(String label, String sys, String dia) {
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
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: sys,
                  style: AppTypography.bodyLarge.copyWith(
                    color: VitalRed.vitalRed500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' / $dia',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Neutral.neutral800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: Neutral.neutral800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _statusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AccentRed.accentRed100,
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
              color: VitalRed.vitalRed500,
            ),
            child: const Icon(
              Icons.priority_high,
              color: Colors.white,
              size: 20,
            ),
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

  Widget _addReadingButton() {
    return GestureDetector(
      onTap: () {},
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

class _BarChartPainter extends CustomPainter {
  final List<String> days;
  final List<int> systolic;
  final List<int> diastolic;

  _BarChartPainter({
    required this.days,
    required this.systolic,
    required this.diastolic,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const minY = 60.0;
    const maxY = 160.0;

    const leftPad = 8.0;
    const rightPad = 8.0;
    const topPad = 12.0;
    const bottomPad = 32.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;

    final slot = chartWidth / days.length;
    const barWidth = 20.0;

    final sysPaint = Paint()..color = VitalRed.vitalRed500;
    final diaPaint = Paint()..color = const Color(0xFFFF6B5A);

    final separatorPaint = Paint()
      ..color = Neutral.neutral400
      ..strokeWidth = 1;

    final textStyle = TextStyle(
      color: Neutral.neutral800,
      fontSize: 12,
      fontFamily: 'Alexandria',
      fontWeight: FontWeight.w500,
    );

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

    for (var i = 0; i < days.length; i++) {
      final cx = leftPad + slot * i + slot / 2;

      final sysVal = systolic[i].toDouble();
      final diaVal = diastolic[i].toDouble();

      final sysTopRatio = (sysVal - minY) / (maxY - minY);
      final diaTopRatio = (diaVal - minY) / (maxY - minY);

      final sysTopY = topPad + chartHeight - (sysTopRatio * chartHeight);
      final diaTopY = topPad + chartHeight - (diaTopRatio * chartHeight);
      final bottomY = topPad + chartHeight;

      final sysRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - barWidth / 2, sysTopY, barWidth, bottomY - sysTopY),
        const Radius.circular(10),
      );
      canvas.drawRRect(sysRect, sysPaint);


      final diaRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - barWidth / 2, diaTopY, barWidth, bottomY - diaTopY),
        const Radius.circular(10),
      );
      canvas.drawRRect(diaRect, diaPaint);

      final tp = TextPainter(
        text: TextSpan(text: days[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, size.height - bottomPad + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => false;
}