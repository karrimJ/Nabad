import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mobile/features/wearables/components/InfoBox.dart';
import 'package:mobile/features/wearables/components/Permission_Box.dart';
import 'package:mobile/features/wearables/components/SUPPORTED_DATA.dart';
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

  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  StreamSubscription<int>? _heartRateSubscription;

  List<BluetoothDevice> _pairedDevices = [];

  BluetoothDevice? _connectedDevice;

  bool _isBluetoothOn = false;
  bool _isLoadingDevices = false;
  bool _isConnecting = false;
  bool _demoConnected = false;

  int? _latestHeartRate;

  String _status =
      "Turn on Bluetooth, pair your watch from phone settings, then connect here.";

  static const String _demoName = "Demo Wearable Device";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _adapterSubscription = FlutterBluePlus.adapterState.listen((state) {
      final isOn = state == BluetoothAdapterState.on;

      if (!mounted) return;

      setState(() {
        _isBluetoothOn = isOn;

        if (!isOn) {
          _pairedDevices = [];
          _connectedDevice = null;
          _demoConnected = false;
          _status = "Bluetooth is off. Turn it on from settings.";
        } else {
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
    if (!Platform.isAndroid) return true;

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

    if (value) {
      try {
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
        }
      } catch (_) {
        // Some Android versions do not allow silent Bluetooth changes.
      }

      await _openBluetoothSettings();
    } else {
      await _disconnectCurrentDevice();

      try {
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOff();
          await _refreshBluetoothState();
          return;
        }
      } catch (_) {
        // On newer Android versions, the app may not be allowed to turn Bluetooth off.
      }

      await _openBluetoothSettings();
    }
  }

  Future<void> _openBluetoothSettings() async {
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

      final devices = Platform.isAndroid
          ? await FlutterBluePlus.bondedDevices
          : <BluetoothDevice>[];

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

        if (_pairedDevices.isEmpty) {
          _status =
              "No paired devices found. Pair your watch from phone Bluetooth settings first.";
        } else {
          _status = "Select a paired wearable from the list.";
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingDevices = false;
        _status = "Could not load paired devices: $e";
      });
    });
  }

  Future<void> _connectPairedDevice(BluetoothDevice device) async {
    final allowed = await _requestBluetoothPermissions();

    if (!allowed) return;

    setState(() {
      _isConnecting = true;
      _demoConnected = false;
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
      _demoConnected = false;
      _latestHeartRate = null;
      _status = _isBluetoothOn
          ? "Disconnected. Select a paired wearable from the list."
          : "Bluetooth is off.";
    });
  }

  void _connectDemoDevice() {
    setState(() {
      _demoConnected = true;
      _connectedDevice = null;
      _latestHeartRate = 76;
      _status = "Connected to $_demoName in demo mode.";
    });
  }

  void _disconnectDemoDevice() {
    setState(() {
      _demoConnected = false;
      _latestHeartRate = null;
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
            _bluetoothCard(),
            const SizedBox(height: 20),
            _statusCard(),
            if (_latestHeartRate != null) ...[
              const SizedBox(height: 20),
              _heartRateCard(),
            ],
            const SizedBox(height: 20),
            _availableDevicesSection(),
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
                      ? "Tap the switch to open Bluetooth settings."
                      : "Turn Bluetooth on to pair your watch.",
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
            "$_latestHeartRate",
            style: AppTypography.headingLarge.copyWith(
              color: VitalRed.vitalRed500,
              fontSize: 48,
              fontWeight: FontWeight.w800,
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
                  "Demo only",
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral700,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _demoConnected ? _disconnectDemoDevice : _connectDemoDevice,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: VitalRed.vitalRed500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              _demoConnected ? "Connected" : "Connect",
              style: TextStyle(color: VitalRed.vitalRed500),
            ),
          ),
        ],
      ),
    );
  }
}