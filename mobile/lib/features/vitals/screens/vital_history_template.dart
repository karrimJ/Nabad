import 'package:flutter/material.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class VitalPeriodData {
  final List<double> points;
  final List<String> labels;
  final String lowest;
  final String average;
  final String highest;

  const VitalPeriodData({
    required this.points,
    required this.labels,
    required this.lowest,
    required this.average,
    required this.highest,
  });
}

class VitalReadingItem {
  final String value;
  final String time;

  const VitalReadingItem({
    required this.value,
    required this.time,
  });
}

class VitalHistoryTemplate extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<String> yAxisLabels;
  final Map<String, VitalPeriodData> periodData;
  final List<VitalReadingItem> recentReadings;

  const VitalHistoryTemplate({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.yAxisLabels,
    required this.periodData,
    required this.recentReadings,
  });

  @override
  State<VitalHistoryTemplate> createState() => _VitalHistoryTemplateState();
}

class _VitalHistoryTemplateState extends State<VitalHistoryTemplate> {
  final List<String> periods = ['Day', 'Week', 'Month', 'Year'];
  String selectedPeriod = 'Week';

  @override
  Widget build(BuildContext context) {
    final currentData =
        widget.periodData[selectedPeriod] ?? widget.periodData.values.first;

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
        centerTitle: true,
        title: Text(
          widget.title,
          style: AppTypography.headingSmall.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: periods.map((period) {
                final isSelected = selectedPeriod == period;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPeriod = period;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? VitalRed.vitalRed500
                            : Neutral.neutral400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        period,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : Neutral.neutral700,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: AppTypography.headingMedium.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Neutral.neutral100,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 34,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: widget.yAxisLabels.map((label) {
                              return Text(
                                label,
                                style: AppTypography.bodySmall.copyWith(
                                  color: Neutral.neutral600,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: CustomPaint(
                                  size: Size.infinite,
                                  painter: _VitalChartPainter(
                                    points: currentData.points,
                                    color: widget.accentColor,
                                    gridColor: Neutral.neutral400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: currentData.labels.map((label) {
                                  return Text(
                                    label,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Neutral.neutral600,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Neutral.neutral200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Lowest: ${currentData.lowest}',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: Neutral.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Average: ${currentData.average}',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: Neutral.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Highest: ${currentData.highest}',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: Neutral.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Reading',
              style: AppTypography.headingMedium.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ...widget.recentReadings.map(
              (reading) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Neutral.neutral100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.accentColor,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        reading.value,
                        style: AppTypography.bodyLarge.copyWith(
                          color: Neutral.neutral900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        reading.time,
                        style: AppTypography.bodySmall.copyWith(
                          color: Neutral.neutral600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: Neutral.neutral500,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.addReading);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: VitalRed.vitalRed500,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Add Reading',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _VitalChartPainter extends CustomPainter {
  final List<double> points;
  final Color color;
  final Color gridColor;

  _VitalChartPainter({
    required this.points,
    required this.color,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final minValue = points.reduce((a, b) => a < b ? a : b);
    final maxValue = points.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue).abs() < 1 ? 1 : (maxValue - minValue);
    final topPadding = range * 0.2;
    final adjustedMin = minValue - topPadding;
    final adjustedMax = maxValue + topPadding;

    Offset pointOffset(int index, double value) {
      final x = points.length == 1
          ? size.width / 2
          : index * (size.width / (points.length - 1));
      final y =
          size.height -
          ((value - adjustedMin) / (adjustedMax - adjustedMin)) * size.height;
      return Offset(x, y);
    }

    final selectedIndex = points.length ~/ 2;
    final selectedX = pointOffset(selectedIndex, points[selectedIndex]).dx;

    final dashedPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 1;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(selectedX, startY),
        Offset(selectedX, startY + 5),
        dashedPaint,
      );
      startY += 9;
    }

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final offset = pointOffset(i, points[i]);
      if (i == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final offset = pointOffset(i, points[i]);
      canvas.drawCircle(offset, 3, dotPaint);
      canvas.drawCircle(offset, 3, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VitalChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}