import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'vital_history_template.dart';

class BloodPressureHistoryScreen extends StatelessWidget {
  const BloodPressureHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VitalHistoryTemplate(
      title: 'Blood Pressure History',
      icon: Icons.monitor_heart,
      accentColor: VitalRed.vitalRed500,
      yAxisLabels: const ['150', '130', '110', '90'],
      periodData: const {
        'Day': VitalPeriodData(
          points: [118, 124, 120, 128, 122, 126, 121],
          labels: ['6A', '8A', '10A', '12P', '2P', '4P', '6P'],
          lowest: '118/76',
          average: '123/79',
          highest: '128/82',
        ),
        'Week': VitalPeriodData(
          points: [120, 126, 118, 124, 122, 128, 121],
          labels: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
          lowest: '118/76',
          average: '123/79',
          highest: '128/82',
        ),
        'Month': VitalPeriodData(
          points: [122, 124, 120, 126, 128, 124, 121],
          labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],
          lowest: '120/77',
          average: '123/79',
          highest: '128/82',
        ),
        'Year': VitalPeriodData(
          points: [124, 126, 122, 120, 128, 124, 121],
          labels: ['Ja', 'Fe', 'Mr', 'Ap', 'My', 'Jn', 'Jl'],
          lowest: '120/77',
          average: '124/80',
          highest: '128/82',
        ),
      },
      recentReadings: const [
        VitalReadingItem(value: '122/78 mmHg', time: 'Today, 09:12'),
        VitalReadingItem(value: '126/80 mmHg', time: 'Yesterday, 08:30 AM'),
        VitalReadingItem(value: '118/76 mmHg', time: 'May 13, 07:45 PM'),
        VitalReadingItem(value: '128/82 mmHg', time: 'May 12, 10:10 AM'),
        VitalReadingItem(value: '121/79 mmHg', time: 'May 11, 08:45 AM'),
      ],
    );
  }
}