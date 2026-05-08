import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/features/wearables/components/InfoBox.dart';
import 'package:mobile/features/wearables/components/Permission_Box.dart';
import 'package:mobile/features/wearables/components/SUPPORTED_DATA.dart';
import 'package:mobile/features/wearables/virtual_iot_reading_service.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class ConnectWearableScreen extends StatefulWidget {
  const ConnectWearableScreen({super.key});

  @override
  State<ConnectWearableScreen> createState() => _ConnectWearableScreenState();
}

class _ConnectWearableScreenState extends State<ConnectWearableScreen> {
  final VirtualIotReadingService _virtualService = VirtualIotReadingService();

  StreamSubscription<VirtualIotReadingSnapshot>? _virtualReadingSubscription;

  bool _demoConnected = false;
  VirtualIotReadingSnapshot? _latestReading;

  String _status =
      "Connect the demo wearable to generate fake vitals every 5 seconds.";

  static const String _demoName = "Demo Wearable Device";

  @override
  void initState() {
    super.initState();

    _virtualReadingSubscription =
        _virtualService.readingsStream.listen((reading) {
      if (!mounted) return;

      setState(() {
        _latestReading = reading;
        _demoConnected = true;
        _status =
            "Virtual IoT demo is running. New readings are saved every 5 seconds.";
      });
    });
  }

  Future<void> _connectDemoDevice() async {
    setState(() {
      _status = "Starting virtual IoT readings...";
    });

    try {
      await _virtualService.start();

      if (!mounted) return;

      setState(() {
        _demoConnected = true;
        _status =
            "Connected to $_demoName. Fake readings are saving every 5 seconds.";
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _demoConnected = false;
        _status = "Could not start virtual IoT demo: $e";
      });
    }
  }

  Future<void> _disconnectDemoDevice() async {
    await _virtualService.stop();

    if (!mounted) return;

    setState(() {
      _demoConnected = false;
      _latestReading = null;
      _status = "Demo wearable stopped.";
    });
  }

  @override
  void dispose() {
    _virtualReadingSubscription?.cancel();
    _virtualService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Connect Wearable",
          style: AppTypography.headingMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _demoDeviceTile(),

            const SizedBox(height: 20),

            _statusCard(),

            if (_latestReading != null) ...[
              const SizedBox(height: 20),
              _virtualReadingsCard(),
            ],

            const SizedBox(height: 20),

            const InfoBox(),

            const SizedBox(height: 20),

            const SupportedDataSection(),

            const SizedBox(height: 20),

            const PermissionBox(),
          ],
        ),
      ),
    );
  }

  Widget _demoDeviceTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: VitalRed.vitalRed500,
            radius: 22,
            child: const Icon(Icons.watch, color: Colors.white),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _demoName,
                  style: AppTypography.headingSmall,
                ),

                const SizedBox(height: 4),

                Text(
                  "Generates heart rate, oxygen, temperature, and blood pressure.",
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),

          OutlinedButton(
            onPressed:
                _demoConnected ? _disconnectDemoDevice : _connectDemoDevice,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: VitalRed.vitalRed500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              _demoConnected ? "Stop" : "Connect",
              style: TextStyle(color: VitalRed.vitalRed500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: VitalRed.vitalRed500),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              _status,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _virtualReadingsCard() {
    final reading = _latestReading;

    if (reading == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Latest Virtual IoT Readings",
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          _readingRow(
            icon: Icons.favorite,
            title: "Heart Rate",
            value: "${reading.heartRate} bpm",
          ),

          _readingRow(
            icon: Icons.air,
            title: "Oxygen Level",
            value: "${reading.oxygen}%",
          ),

          _readingRow(
            icon: Icons.thermostat,
            title: "Temperature",
            value: "${reading.temperature.toStringAsFixed(1)} °C",
          ),

          _readingRow(
            icon: Icons.monitor_heart,
            title: "Blood Pressure",
            value: reading.bloodPressureText,
          ),

          const SizedBox(height: 8),

          Text(
            "Each new set is saved to Firebase under vitals and iotReadings.",
            style: AppTypography.bodySmall.copyWith(
              color: Neutral.neutral700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _readingRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: VitalRed.vitalRed500),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyMedium,
            ),
          ),

          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: VitalRed.vitalRed500,
            ),
          ),
        ],
      ),
    );
  }
}