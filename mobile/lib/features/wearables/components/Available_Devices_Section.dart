import 'package:flutter/material.dart';
import 'package:mobile/features/wearables/components/device_item.dart';

class AvailableDevicesSection extends StatelessWidget {
  const AvailableDevicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Available Devices"),
        SizedBox(height: 12),
        DeviceItem(),
        DeviceItem(),
        DeviceItem(),
      ],
    );
  }
}