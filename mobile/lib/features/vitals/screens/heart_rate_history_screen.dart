import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/components/auth_button.dart';

class HeartRateHistoryScreen extends StatefulWidget {
  const HeartRateHistoryScreen({super.key});

  @override
  State<HeartRateHistoryScreen> createState() =>
      _HeartRateHistoryScreenState();
}

class _HeartRateHistoryScreenState extends State<HeartRateHistoryScreen> {
  int _selectedTab = 1; // 0=Day, 1=Week, 2=Month, 3=Year

  final List<double> _weekReadings = [76, 80, 79, 80, 78, 80, 76];
  final List<String> _weekLabels = [
    'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'
  ];

  final List<_Reading> _recentReadings = [
    _Reading('78 bpm', 'Today, 09:12'),
    _Reading('82 bpm', 'Yestetrday, 08:30 AM'),
    _Reading('76 bpm', 'May 13, 07:45 PM'),
    _Reading('80 bpm', 'May 12, 10:10 AM'),
    _Reading('79 bpm', 'May 11, 08:45 AM'),
  ];

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
          'Heart Rate History',
          style: AppTypography.headingSmall.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _periodTabs(),
                  const SizedBox(height: 20),
                  Text(
                    'Heart Rate History',
                    style: AppTypography.headingSmall.copyWith(
                      color: Neutral.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _chartCard(),
                  const SizedBox(height: 20),
                  Text(
                    'Recent Reading',
                    style: AppTypography.headingSmall.copyWith(
                      color: Neutral.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._recentReadings.map(_recentRow),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: AuthButton(
              text: '+ Add Reading',
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodTabs() {
    final labels = ['Day', 'Week', 'Month', 'Year'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(labels.length, (i) {
        final selected = _selectedTab == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedTab = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? VitalRed.vitalRed500 : Neutral.neutral100,
              borderRadius: BorderRadius.circular(24),
              border: selected
                  ? null
                  : Border.all(color: Neutral.neutral400, width: 1),
            ),
            child: Text(
              labels[i],
              style: AppTypography.bodyMedium.copyWith(
                color: selected ? Neutral.neutral100 : Neutral.neutral800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
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
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _LineChartPainter(
                readings: _weekReadings,
                xLabels: _weekLabels,
                highlightIndex: 4,
                highlightLabel: '78 bpm',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Neutral.neutral200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lowest: 76 bpm',
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Average: 79 bpm',
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Highest: 84 bpm',
                  style: AppTypography.bodySmall.copyWith(
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

  Widget _recentRow(_Reading r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: VitalRed.vitalRed500, size: 22),
          const SizedBox(width: 12),
          Text(
            r.value,
            style: AppTypography.bodyLarge.copyWith(
              color: Neutral.neutral900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            r.time,
            style: AppTypography.bodySmall.copyWith(
              color: Neutral.neutral600,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right,
            color: Neutral.neutral600,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _Reading {
  final String value;
  final String time;
  _Reading(this.value, this.time);
}

class _LineChartPainter extends CustomPainter {
  final List<double> readings;
  final List<String> xLabels;
  final int? highlightIndex;
  final String? highlightLabel;

  _LineChartPainter({
    required this.readings,
    required this.xLabels,
    this.highlightIndex,
    this.highlightLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const minY = 50.0;
    const maxY = 90.0;
    const yLabels = [90.0, 80.0, 70.0, 60.0, 50.0];

    const leftPad = 32.0;
    const rightPad = 12.0;
    const topPad = 24.0;
    const bottomPad = 28.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;

    final textStyle = TextStyle(
      color: Neutral.neutral600,
      fontSize: 11,
      fontFamily: 'Alexandria',
    );

    final gridPaint = Paint()
      ..color = Neutral.neutral300
      ..strokeWidth = 1;

    for (final yVal in yLabels) {
      final ratio = (yVal - minY) / (maxY - minY);
      final y = topPad + chartHeight - (ratio * chartHeight);

      final tp = TextPainter(
        text: TextSpan(text: yVal.toInt().toString(), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        gridPaint,
      );
    }

    final linePaint = Paint()
      ..color = VitalRed.vitalRed500
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = Neutral.neutral100
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = VitalRed.vitalRed500
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final highlightDotPaint = Paint()..color = VitalRed.vitalRed500;

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
        final prev = points[i - 1];
        final mid = Offset((prev.dx + x) / 2, (prev.dy + y) / 2);
        path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
        if (i == readings.length - 1) {
          path.lineTo(x, y);
        }
      }
    }

    canvas.drawPath(path, linePaint);

    for (var i = 0; i < points.length; i++) {
      if (i == highlightIndex) {
        canvas.drawCircle(points[i], 5, highlightDotPaint);
      } else {
        canvas.drawCircle(points[i], 4, dotPaint);
        canvas.drawCircle(points[i], 4, dotBorderPaint);
      }
    }

    if (highlightIndex != null && highlightLabel != null) {
      final p = points[highlightIndex!];

      final dashedPaint = Paint()
        ..color = VitalRed.vitalRed500.withOpacity(0.5)
        ..strokeWidth = 1;
      double dashY = topPad;
      while (dashY < p.dy - 4) {
        canvas.drawLine(
          Offset(p.dx, dashY),
          Offset(p.dx, dashY + 4),
          dashedPaint,
        );
        dashY += 8;
      }

      final tp = TextPainter(
        text: TextSpan(
          text: highlightLabel,
          style: TextStyle(
            color: Neutral.neutral900,
            fontSize: 11,
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final boxRect = Rect.fromCenter(
        center: Offset(p.dx, topPad - 4),
        width: tp.width + 14,
        height: 22,
      );
      final boxPaint = Paint()..color = Neutral.neutral100;
      final borderPaint = Paint()
        ..color = Neutral.neutral400
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      final rrect = RRect.fromRectAndRadius(boxRect, const Radius.circular(6));
      canvas.drawRRect(rrect, boxPaint);
      canvas.drawRRect(rrect, borderPaint);
      tp.paint(
        canvas,
        Offset(p.dx - tp.width / 2, topPad - 4 - tp.height / 2),
      );
    }

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