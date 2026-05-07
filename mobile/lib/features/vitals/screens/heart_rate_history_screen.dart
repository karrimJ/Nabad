import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'vital_history_template.dart';

class HeartRateHistoryScreen extends StatelessWidget {
  const HeartRateHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VitalHistoryTemplate(
      title: 'Heart Rate History',
      icon: Icons.favorite,
      accentColor: VitalRed.vitalRed500,
      yAxisLabels: const ['90', '80', '70', '50'],
      periodData: const {
        'Day': VitalPeriodData(
          points: [76, 82, 78, 80, 79, 84, 77],
          labels: ['6A', '8A', '10A', '12P', '2P', '4P', '6P'],
          lowest: '76 bpm',
          average: '79 bpm',
          highest: '84 bpm',
        ),
        'Week': VitalPeriodData(
          points: [76, 83, 75, 78, 78, 80, 75],
          labels: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
          lowest: '76 bpm',
          average: '79 bpm',
          highest: '84 bpm',
        ),
        'Month': VitalPeriodData(
          points: [78, 80, 76, 82, 79, 81, 77],
          labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],
          lowest: '76 bpm',
          average: '79 bpm',
          highest: '82 bpm',
        ),
        'Year': VitalPeriodData(
          points: [77, 79, 80, 78, 82, 81, 79],
          labels: ['Ja', 'Fe', 'Mr', 'Ap', 'My', 'Jn', 'Jl'],
          lowest: '77 bpm',
          average: '79 bpm',
          highest: '82 bpm',
        ),
      },
      recentReadings: const [
        VitalReadingItem(value: '78 bpm', time: 'Today, 09:12'),
        VitalReadingItem(value: '82 bpm', time: 'Yesterday, 08:30 AM'),
        VitalReadingItem(value: '76 bpm', time: 'May 13, 07:45 PM'),
        VitalReadingItem(value: '80 bpm', time: 'May 12, 10:10 AM'),
        VitalReadingItem(value: '79 bpm', time: 'May 11, 08:45 AM'),
      ],
    );
  }
}