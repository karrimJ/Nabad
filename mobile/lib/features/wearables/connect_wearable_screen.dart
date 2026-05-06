import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mobile/features/wearables/wearable_ble_service.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class ConnectWearableScreen extends StatefulWidget {
  const ConnectWearableScreen({super.key});

  @override
  State<ConnectWearableScreen> createState() => _ConnectWearableScreenState();
}

class _ConnectWearableScreenState extends State<ConnectWearableScreen> {
  final WearableBleService _bleService = WearableBleService();

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<int>? _heartRateSubscription;

  List<ScanResult> _devices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String _status = "Press scan to find nearby heart-rate devices.";
  int? _latestHeartRate;

  @override
  void initState() {
    super.initState();

    _heartRateSubscription = _bleService.heartRateStream.listen((bpm) {
      setState(() {
        _latestHeartRate = bpm;
        _status = "Receiving heart rate from wearable.";
      });
    });
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _devices = [];
      _status = "Scanning for heart-rate devices...";
    });

    try {
      await _scanSubscription?.cancel();

      _scanSubscription = _bleService.scanResults.listen((results) {
        final unique = <String, ScanResult>{};

        for (final result in results) {
          final id = result.device.remoteId.toString();
          unique[id] = result;
        }

        setState(() {
          _devices = unique.values.toList();
        });
      });

      await _bleService.startScan();

      await FlutterBluePlus.isScanning.where((scanning) => !scanning).first;

      if (mounted) {
        setState(() {
          _isScanning = false;
          if (_devices.isEmpty) {
            _status =
                "No heart-rate devices found. Put your Polar M430 in HR broadcast mode and scan again.";
          } else {
            _status = "Select your wearable from the list.";
          }
        });
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
        _status = "Bluetooth error: $e";
      });
    }
  }

  Future<void> _connect(ScanResult result) async {
    setState(() {
      _isConnecting = true;
      _status = "Connecting to device...";
    });

    try {
      await _bleService.connectToDevice(result.device);

      final name = _deviceName(result);

      setState(() {
        _isConnecting = false;
        _status = "Connected to $name";
      });
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _status = "Connection failed: $e";
      });
    }
  }

  String _deviceName(ScanResult result) {
    if (result.device.platformName.isNotEmpty) {
      return result.device.platformName;
    }

    if (result.advertisementData.advName.isNotEmpty) {
      return result.advertisementData.advName;
    }

    return result.device.remoteId.toString();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _heartRateSubscription?.cancel();
    _bleService.dispose();
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
            _statusCard(),
            const SizedBox(height: 16),
            _scanButton(),
            const SizedBox(height: 20),
            _heartRateCard(),
            const SizedBox(height: 20),
            Text(
              "Available Devices",
              style: AppTypography.headingSmall,
            ),
            const SizedBox(height: 12),
            if (_devices.isEmpty)
              Text(
                "No devices yet.",
                style: AppTypography.bodyMedium.copyWith(
                  color: Neutral.neutral700,
                ),
              )
            else
              ..._devices.map(_deviceTile),
            const SizedBox(height: 20),
            _helpBox(),
          ],
        ),
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
          const Icon(Icons.bluetooth, color: VitalRed.vitalRed500),
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

  Widget _scanButton() {
    return ElevatedButton.icon(
      onPressed: _isScanning || _isConnecting ? null : _startScan,
      icon: _isScanning
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.search),
      label: Text(_isScanning ? "Scanning..." : "Scan for Wearables"),
      style: ElevatedButton.styleFrom(
        backgroundColor: VitalRed.vitalRed500,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _heartRateCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Neutral.neutral300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            "Live Heart Rate",
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _latestHeartRate == null ? "--" : "$_latestHeartRate",
            style: AppTypography.headingLarge.copyWith(
              color: VitalRed.vitalRed500,
              fontSize: 48,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "bpm",
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _deviceTile(ScanResult result) {
    final name = _deviceName(result);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Neutral.neutral300,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: const Icon(Icons.watch, color: VitalRed.vitalRed500),
        title: Text(
          name,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          result.device.remoteId.toString(),
          style: AppTypography.bodySmall,
        ),
        trailing: _isConnecting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
        onTap: _isConnecting ? null : () => _connect(result),
      ),
    );
  }

  Widget _helpBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "For Polar M430: start a training session, open the quick menu, then turn on HR visible to other device. Keep the watch close to your phone while scanning.",
        style: AppTypography.bodySmall.copyWith(
          color: Neutral.neutral700,
          height: 1.5,
        ),
      ),
    );
  }
}