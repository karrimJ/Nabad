import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mobile/features/wearables/components/InfoBox.dart';
import 'package:mobile/features/wearables/components/Permission_Box.dart';
import 'package:mobile/features/wearables/components/SUPPORTED_DATA.dart';
import 'package:mobile/features/wearables/virtual_iot_reading_service.dart';
import 'package:mobile/features/wearables/wearable_ble_service.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:permission_handler/permission_handler.dart';

class ConnectWearableScreen extends StatefulWidget {
  const ConnectWearableScreen({super.key});

  @override
  State<ConnectWearableScreen> createState() => _ConnectWearableScreenState();
}

class _ConnectWearableScreenState extends State<ConnectWearableScreen>
    with WidgetsBindingObserver {
  final WearableBleService _bleService = WearableBleService();
  final VirtualIotReadingService _virtualService = VirtualIotReadingService();

  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  StreamSubscription<int>? _heartRateSubscription;
  StreamSubscription<VirtualIotReadingSnapshot>? _virtualReadingSubscription;

  List<BluetoothDevice> _pairedDevices = [];

  BluetoothDevice? _connectedDevice;
  VirtualIotReadingSnapshot? _latestVirtualReading;

  bool _isBluetoothOn = false;
  bool _isLoadingDevices = false;
  bool _isConnecting = false;
  bool _demoConnected = false;
  bool _isStartingDemo = false;

  int? _latestHeartRate;

  String _status =
      "Turn on Bluetooth, pair your watch from phone settings, then connect here.";

  static const String _demoName = "Demo Wearable Device";

  bool get _isAndroid {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _adapterSubscription = FlutterBluePlus.adapterState.listen((state) {
      final isOn = state == BluetoothAdapterState.on;

      if (!mounted) return;

      setState(() {
        _isBluetoothOn = isOn;

        if (!isOn && !_demoConnected) {
          _pairedDevices = [];
          _connectedDevice = null;
          _status = "Bluetooth is off. Turn it on from settings.";
        } else if (isOn && !_demoConnected) {
          _status = "Bluetooth is on. Loading paired devices...";
        }
      });

      if (isOn) {
        _loadPairedDevices();
      }
    });

    _heartRateSubscription = _bleService.heartRateStream.listen((bpm) {
      if (!mounted) return;

      setState(() {
        _latestHeartRate = bpm;
        _status = "Receiving heart rate from wearable.";
      });
    });

    _virtualReadingSubscription =
        _virtualService.readingsStream.listen((reading) {
      if (!mounted) return;

      setState(() {
        _latestVirtualReading = reading;
        _latestHeartRate = reading.heartRate;
        _demoConnected = true;
        _isStartingDemo = false;
        _connectedDevice = null;
        _status =
            "Virtual IoT demo is running. New readings are saved every 5 seconds.";
      });
    });

    _refreshBluetoothState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshBluetoothState();
    }
  }

  Future<void> _refreshBluetoothState() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      final isOn = state == BluetoothAdapterState.on;

      if (!mounted) return;

      setState(() {
        _isBluetoothOn = isOn;
      });

      if (isOn) {
        await _loadPairedDevices();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = "Could not check Bluetooth state: $e";
      });
    }
  }

  Future<bool> _requestBluetoothPermissions() async {
    if (!_isAndroid) return true;

    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final hasBlockedPermission = statuses.values.any(
      (status) =>
          status.isDenied ||
          status.isPermanentlyDenied ||
          status.isRestricted,
    );

    if (hasBlockedPermission) {
      if (!mounted) return false;

      setState(() {
        _status = "Bluetooth permission is required to connect wearables.";
      });

      return false;
    }

    return true;
  }

  Future<void> _onBluetoothSwitchChanged(bool value) async {
    final allowed = await _requestBluetoothPermissions();

    if (!allowed) return;

    if (!value) {
      await _disconnectCurrentDevice();
      await _disconnectDemoDevice();

      if (!mounted) return;

      setState(() {
        _isBluetoothOn = false;
        _status =
            "App Bluetooth connection is off. Permissions were not revoked.";
      });

      return;
    }

    if (_isAndroid) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (_) {
        await _openBluetoothSettings();
      }
    }

    if (!mounted) return;

    setState(() {
      _isBluetoothOn = true;
      _status = "Bluetooth is on. You can connect the demo wearable.";
    });

    await _loadPairedDevices();
  }

  Future<void> _openBluetoothSettings() async {
    if (!_isAndroid) return;

    try {
      await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
    } catch (_) {
      await AppSettings.openAppSettings();
    }
  }

  Future<void> _loadPairedDevices() async {
    if (_isLoadingDevices) return;

    setState(() {
      _isLoadingDevices = true;
    });

    try {
      final allowed = await _requestBluetoothPermissions();

      if (!allowed) {
        if (!mounted) return;

        setState(() {
          _isLoadingDevices = false;
        });

        return;
      }

      final devices =
          _isAndroid ? await FlutterBluePlus.bondedDevices : <BluetoothDevice>[];

      final uniqueDevices = <String, BluetoothDevice>{};

      for (final device in devices) {
        uniqueDevices[device.remoteId.toString()] = device;
      }

      final sortedDevices = uniqueDevices.values.toList()
        ..sort((a, b) => _deviceName(a).compareTo(_deviceName(b)));

      if (!mounted) return;

      setState(() {
        _pairedDevices = sortedDevices;
        _isLoadingDevices = false;

        if (!_demoConnected) {
          if (_pairedDevices.isEmpty) {
            _status =
                "No paired devices found. Pair your watch from phone Bluetooth settings first.";
          } else {
            _status = "Select a paired wearable from the list.";
          }
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingDevices = false;
        _status = "Could not load paired devices: $e";
      });
    }
  }

  Future<void> _connectPairedDevice(BluetoothDevice device) async {
    final allowed = await _requestBluetoothPermissions();

    if (!allowed) return;

    await _virtualService.stop();

    setState(() {
      _isConnecting = true;
      _demoConnected = false;
      _latestVirtualReading = null;
      _status = "Connecting to ${_deviceName(device)}...";
    });

    try {
      await _bleService.connectToDevice(device);

      if (!mounted) return;

      setState(() {
        _connectedDevice = device;
        _isConnecting = false;
        _status = "Connected to ${_deviceName(device)}.";
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isConnecting = false;
        _connectedDevice = null;
        _status =
            "Connection failed. This device may not expose heart-rate data through BLE. Error: $e";
      });
    }
  }

  Future<void> _disconnectCurrentDevice() async {
    try {
      await _bleService.disconnect();
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _connectedDevice = null;

      if (!_demoConnected) {
        _latestHeartRate = null;
      }

      _status = _isBluetoothOn
          ? "Disconnected. Select a paired wearable from the list."
          : "Bluetooth is off.";
    });
  }

  Future<void> _connectDemoDevice() async {
    if (_isStartingDemo || _demoConnected) return;

    setState(() {
      _isStartingDemo = true;
      _status = "Starting virtual IoT demo...";
    });

    try {
      await _disconnectCurrentDevice();
      await _virtualService.start();

      if (!mounted) return;

      setState(() {
        _demoConnected = true;
        _isStartingDemo = false;
        _connectedDevice = null;
        _status =
            "Connected to $_demoName. Fake readings are saving every 5 seconds.";
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _demoConnected = false;
        _isStartingDemo = false;
        _status = "Could not start virtual IoT demo: $e";
      });
    }
  }

  Future<void> _disconnectDemoDevice() async {
    await _virtualService.stop();

    if (!mounted) return;

    setState(() {
      _demoConnected = false;
      _isStartingDemo = false;
      _latestVirtualReading = null;

      if (_connectedDevice == null) {
        _latestHeartRate = null;
      }

      _status = "Demo wearable disconnected.";
    });
  }

  String _deviceName(BluetoothDevice device) {
    final name = device.platformName.trim();

    if (name.isNotEmpty) {
      return name;
    }

    return "Paired Wearable";
  }

  bool _isDeviceConnected(BluetoothDevice device) {
    return _connectedDevice?.remoteId.toString() == device.remoteId.toString();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _adapterSubscription?.cancel();
    _heartRateSubscription?.cancel();
    _virtualReadingSubscription?.cancel();

    _virtualService.dispose();
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
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.wearables,
            );
          },
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
            _bluetoothCard(),
            const SizedBox(height: 20),
            _statusCard(),
            if (_latestHeartRate != null) ...[
              const SizedBox(height: 20),
              _heartRateCard(),
            ],
            if (_latestVirtualReading != null) ...[
              const SizedBox(height: 20),
              _virtualReadingsCard(),
            ],
            const SizedBox(height: 20),
            _availableDevicesSection(),
            const SizedBox(height: 20),
            InfoBox(),
            const SizedBox(height: 20),
            SupportedDataSection(),
            const SizedBox(height: 20),
            PermissionBox(),
          ],
        ),
      ),
    );
  }

  Widget _bluetoothCard() {
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
            child: const Icon(Icons.bluetooth, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isBluetoothOn ? "Bluetooth is on" : "Bluetooth is off",
                  style: AppTypography.headingSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  _isBluetoothOn
                      ? "Bluetooth access is active. You can connect demo or paired devices."
                      : "Turn Bluetooth on to connect your wearable.",
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: _isBluetoothOn,
            onChanged: _onBluetoothSwitchChanged,
            activeColor: VitalRed.vitalRed500,
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
          if (_isBluetoothOn)
            IconButton(
              onPressed: _loadPairedDevices,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
    );
  }

  Widget _heartRateCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            _demoConnected ? "Demo Heart Rate" : "Live Heart Rate",
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$_latestHeartRate",
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

  Widget _virtualReadingsCard() {
    final reading = _latestVirtualReading;

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

  Widget _availableDevicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Devices",
          style: AppTypography.headingSmall,
        ),
        const SizedBox(height: 12),
        if (_isLoadingDevices)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
        if (!_isLoadingDevices)
          ..._pairedDevices.map((device) => _deviceTile(device)),
        _demoDeviceTile(),
        if (!_isLoadingDevices && _pairedDevices.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Only paired devices are shown. Pair your Polar M430 or watch from phone Bluetooth settings first.",
              style: AppTypography.bodySmall.copyWith(
                color: Neutral.neutral700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _deviceTile(BluetoothDevice device) {
    final isConnected = _isDeviceConnected(device);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.watch, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _deviceName(device),
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  "Paired device",
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral700,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _isConnecting
                ? null
                : () {
                    if (isConnected) {
                      _disconnectCurrentDevice();
                    } else {
                      _connectPairedDevice(device);
                    }
                  },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: VitalRed.vitalRed500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              isConnected ? "Connected" : "Connect",
              style: TextStyle(color: VitalRed.vitalRed500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _demoDeviceTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.watch, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _demoName,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  "Fake IoT readings every 5 seconds",
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral700,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _isStartingDemo
                ? null
                : _demoConnected
                    ? _disconnectDemoDevice
                    : _connectDemoDevice,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: VitalRed.vitalRed500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              _isStartingDemo
                  ? "Starting..."
                  : _demoConnected
                      ? "Stop"
                      : "Connect",
              style: TextStyle(color: VitalRed.vitalRed500),
            ),
          ),
        ],
      ),
    );
  }
}