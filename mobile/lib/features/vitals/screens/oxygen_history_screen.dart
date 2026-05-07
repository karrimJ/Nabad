import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import '../data/vitals_service.dart';
import '../data/vital_type.dart';
import 'vital_history_template.dart';

class OxygenHistoryScreen extends StatelessWidget {
  const OxygenHistoryScreen({super.key});

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
      stream: service.readingsStream(type: VitalType.oxygen, limit: 20),
      builder: (context, snapshot) {
        final readings = snapshot.data ?? [];

        final recentReadings = readings.map((r) => VitalReadingItem(
          value: '${(r.value ?? 0).toStringAsFixed(0)}%',
          time: _formatTime(r.recordedAt),
        )).toList();

        final List<double> values = readings
            .map((r) => r.value as double)
            .toList();

        final lowest = values.isEmpty
            ? '--'
            : '${values.reduce((a, b) => a < b ? a : b).toStringAsFixed(0)}%';
        final highest = values.isEmpty
            ? '--'
            : '${values.reduce((a, b) => a > b ? a : b).toStringAsFixed(0)}%';
        final average = values.isEmpty
            ? '--'
            : '${(values.reduce((a, b) => a + b) / values.length).toStringAsFixed(0)}%';

        final List<double> displayPoints = values.isEmpty
            ? [96.0, 97.0, 95.0, 96.0, 96.0, 98.0, 97.0]
            : List<double>.from(
                (values.length > 7 ? values.sublist(0, 7) : values).reversed);

        final weekLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

        return VitalHistoryTemplate(
          title: 'Oxygen Level History',
          icon: Icons.air,
          accentColor: VitalRed.vitalRed500,
          yAxisLabels: const ['100', '95', '90', '85'],
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