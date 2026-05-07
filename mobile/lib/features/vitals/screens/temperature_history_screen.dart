import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'vital_history_template.dart';

class TemperatureHistoryScreen extends StatelessWidget {
  const TemperatureHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VitalHistoryTemplate(
      title: 'Temperature History',
      icon: Icons.thermostat,
      accentColor: VitalRed.vitalRed500,
      yAxisLabels: const ['38', '37', '36', '35'],
      periodData: const {
        'Day': VitalPeriodData(
          points: [36.5, 36.8, 36.7, 37.0, 36.9, 36.8, 36.6],
          labels: ['6A', '8A', '10A', '12P', '2P', '4P', '6P'],
          lowest: '36.5°C',
          average: '36.8°C',
          highest: '37.0°C',
        ),
        'Week': VitalPeriodData(
          points: [36.7, 36.9, 36.6, 36.8, 36.8, 37.0, 36.7],
          labels: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
          lowest: '36.6°C',
          average: '36.8°C',
          highest: '37.0°C',
        ),
        'Month': VitalPeriodData(
          points: [36.6, 36.7, 36.9, 36.8, 37.0, 36.9, 36.8],
          labels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],
          lowest: '36.6°C',
          average: '36.8°C',
          highest: '37.0°C',
        ),
        'Year': VitalPeriodData(
          points: [36.8, 36.9, 36.7, 36.8, 36.9, 37.0, 36.8],
          labels: ['Ja', 'Fe', 'Mr', 'Ap', 'My', 'Jn', 'Jl'],
          lowest: '36.7°C',
          average: '36.8°C',
          highest: '37.0°C',
        ),
      },
      recentReadings: const [
        VitalReadingItem(value: '36.8 °C', time: 'Today, 09:12'),
        VitalReadingItem(value: '37.0 °C', time: 'Yesterday, 08:30 AM'),
        VitalReadingItem(value: '36.6 °C', time: 'May 13, 07:45 PM'),
        VitalReadingItem(value: '36.9 °C', time: 'May 12, 10:10 AM'),
        VitalReadingItem(value: '36.7 °C', time: 'May 11, 08:45 AM'),
      ],
    );
  }
}