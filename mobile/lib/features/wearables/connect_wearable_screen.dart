import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/features/wearables/components/bluetooth_card.dart';
import 'package:mobile/features/wearables/components/Available_Devices_Section.dart';
import 'package:mobile/features/wearables/components/InfoBox.dart';
import 'package:mobile/features/wearables/components/SUPPORTED_DATA.dart';
import 'package:mobile/features/wearables/components/Permission_Box.dart';

class ConnectWearableScreen extends StatelessWidget {
  const ConnectWearableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        centerTitle: true,
        title: Text(
          "Connect Wearable",
          style: AppTypography.headingMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            BluetoothCard(),
            SizedBox(height: 20),
            AvailableDevicesSection(),
            SizedBox(height: 20),
            InfoBox(),
            SizedBox(height: 20),
            SupportedDataSection(),
            SizedBox(height: 20),
            PermissionBox(),
          ],
        ),
      ),
    );
  }
}