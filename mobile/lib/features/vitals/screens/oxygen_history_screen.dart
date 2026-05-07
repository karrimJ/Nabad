import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'vital_history_template.dart';

class OxygenHistoryScreen extends StatelessWidget {
  const OxygenHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VitalHistoryTemplate(
      title: 'Oxygen Level History',
      icon: Icons.air,
      accentColor: VitalRed.vitalRed500,
      yAxisLabels: const ['100', '95', '90', '85'],
      periodData: const {
        'Day': VitalPeriodData(
          points: [97, 98, 96, 97, 99, 98, 97],
          labels: ['6A', '8A', '10A', '12P', '2P', '4P', '6P'],
          lowest: '96%',
          average: '97%',
          highest: '99%',
        ),
        'Week': VitalPeriodData(
          points: [96, 97, 95, 96, 96, 98, 97],
          labels: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
          lowest: '95%',
          average: '96%',
          highest: '98%',
        ),
        'Month': VitalPeriodData(
          points: [95, 96, 97, 96, 98, 97, 96],
          labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],
          lowest: '95%',
          average: '96%',
          highest: '98%',
        ),
        'Year': VitalPeriodData(
          points: [96, 97, 96, 95, 97, 98, 97],
          labels: ['Ja', 'Fe', 'Mr', 'Ap', 'My', 'Jn', 'Jl'],
          lowest: '95%',
          average: '96%',
          highest: '98%',
        ),
      },
      recentReadings: const [
        VitalReadingItem(value: '97%', time: 'Today, 09:12'),
        VitalReadingItem(value: '96%', time: 'Yesterday, 08:30 AM'),
        VitalReadingItem(value: '95%', time: 'May 13, 07:45 PM'),
        VitalReadingItem(value: '98%', time: 'May 12, 10:10 AM'),
        VitalReadingItem(value: '94%', time: 'May 11, 08:45 AM'),
      ],
    );
  }
}