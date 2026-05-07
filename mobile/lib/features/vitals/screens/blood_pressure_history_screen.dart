import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import '../data/vitals_service.dart';
import '../data/vital_type.dart';
import '../data/vital_reading_model.dart';
import 'vital_history_template.dart';

class BloodPressureHistoryScreen extends StatelessWidget {
  const BloodPressureHistoryScreen({super.key});

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour:$minute $period';

    if (date == today) return 'Today, $time';
    if (date == yesterday) return 'Yesterday, $time';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, $time';
  }

  @override
  Widget build(BuildContext context) {
    final service = VitalsService();

    return StreamBuilder(
      stream: service.readingsStream(type: VitalType.bloodPressure, limit: 20),
      builder: (context, snapshot) {
        final readings = snapshot.data ?? [];

        final recentReadings = readings.map((r) {
          final sys = (r.systolic ?? 0).toStringAsFixed(0);
          final dia = (r.diastolic ?? 0).toStringAsFixed(0);
          return VitalReadingItem(
            value: '$sys/$dia mmHg',
            time: _formatTime(r.recordedAt),
          );
        }).toList();

        final systolicValues = readings
            .map((r) => r.systolic ?? 0.0)
            .toList();

        final lowest = systolicValues.isEmpty
            ? '--'
            : '${systolicValues.reduce((a, b) => a < b ? a : b).toStringAsFixed(0)} mmHg';
        final highest = systolicValues.isEmpty
            ? '--'
            : '${systolicValues.reduce((a, b) => a > b ? a : b).toStringAsFixed(0)} mmHg';
        final average = systolicValues.isEmpty
            ? '--'
            : '${(systolicValues.reduce((a, b) => a + b) / systolicValues.length).toStringAsFixed(0)} mmHg';

        final List<double> displayPoints = systolicValues.isEmpty
            ? [120.0, 126.0, 118.0, 124.0, 122.0, 128.0, 121.0]
            : List<double>.from(
                (systolicValues.length > 7
                    ? systolicValues.sublist(0, 7)
                    : systolicValues).reversed);

        final weekLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

        return VitalHistoryTemplate(
          title: 'Blood Pressure History',
          icon: Icons.monitor_heart,
          accentColor: VitalRed.vitalRed500,
          yAxisLabels: const ['150', '130', '110', '90'],
          periodData: {
            'Day': VitalPeriodData(
              points: displayPoints,
              labels: weekLabels,
              lowest: lowest,
              average: average,
              highest: highest,
            ),
            'Week': VitalPeriodData(
              points: displayPoints,
              labels: weekLabels,
              lowest: lowest,
              average: average,
              highest: highest,
            ),
            'Month': VitalPeriodData(
              points: displayPoints,
              labels: weekLabels,
              lowest: lowest,
              average: average,
              highest: highest,
            ),
            'Year': VitalPeriodData(
              points: displayPoints,
              labels: weekLabels,
              lowest: lowest,
              average: average,
              highest: highest,
            ),
          },
          recentReadings: recentReadings.isEmpty
              ? const [VitalReadingItem(value: 'No readings yet', time: '')]
              : recentReadings,
        );
      },
    );
  }
}