import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'vital_history_template.dart';

class GlucoseHistoryScreen extends StatelessWidget {
  const GlucoseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VitalHistoryTemplate(
      title: 'Glucose Level History',
      icon: Icons.water_drop,
      accentColor: VitalRed.vitalRed500,
      yAxisLabels: const ['140', '110', '90', '70'],
      periodData: const {
        'Day': VitalPeriodData(
          points: [102, 108, 96, 112, 104, 110, 99],
          labels: ['6A', '8A', '10A', '12P', '2P', '4P', '6P'],
          lowest: '96 mg/dL',
          average: '104 mg/dL',
          highest: '112 mg/dL',
        ),
        'Week': VitalPeriodData(
          points: [98, 110, 102, 108, 105, 112, 100],
          labels: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
          lowest: '98 mg/dL',
          average: '105 mg/dL',
          highest: '112 mg/dL',
        ),
        'Month': VitalPeriodData(
          points: [100, 106, 102, 110, 108, 112, 104],
          labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],
          lowest: '100 mg/dL',
          average: '106 mg/dL',
          highest: '112 mg/dL',
        ),
        'Year': VitalPeriodData(
          points: [104, 108, 106, 102, 110, 112, 105],
          labels: ['Ja', 'Fe', 'Mr', 'Ap', 'My', 'Jn', 'Jl'],
          lowest: '102 mg/dL',
          average: '106 mg/dL',
          highest: '112 mg/dL',
        ),
      },
      recentReadings: const [
        VitalReadingItem(value: '108 mg/dL', time: 'Today, 09:12'),
        VitalReadingItem(value: '102 mg/dL', time: 'Yesterday, 08:30 AM'),
        VitalReadingItem(value: '96 mg/dL', time: 'May 13, 07:45 PM'),
        VitalReadingItem(value: '110 mg/dL', time: 'May 12, 10:10 AM'),
        VitalReadingItem(value: '104 mg/dL', time: 'May 11, 08:45 AM'),
      ],
    );
  }
}