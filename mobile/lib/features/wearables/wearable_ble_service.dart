import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class WearableBleService {
  static final Guid heartRateServiceUuid = Guid("180D");
  static final Guid heartRateMeasurementUuid = Guid("2A37");

  BluetoothDevice? connectedDevice;
  StreamSubscription<List<int>>? _heartRateSubscription;

  final StreamController<int> _heartRateController =
      StreamController<int>.broadcast();

  Stream<int> get heartRateStream => _heartRateController.stream;

  Future<void> initBluetooth() async {
    final supported = await FlutterBluePlus.isSupported;
    if (!supported) {
      throw Exception("Bluetooth is not supported on this device.");
    }

    if (Platform.isAndroid) {
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      await FlutterBluePlus.turnOn();
    }

    await FlutterBluePlus.adapterState
        .where((state) => state == BluetoothAdapterState.on)
        .first;
  }

  Future<void> startScan() async {
    await initBluetooth();

    await FlutterBluePlus.stopScan();

    await FlutterBluePlus.startScan(
      withServices: [heartRateServiceUuid],
      timeout: const Duration(seconds: 15),
    );
  }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Future<void> connectToDevice(BluetoothDevice device) async {
    await FlutterBluePlus.stopScan();

    connectedDevice = device;

    await device.connect(
  license: License.free,
  timeout: const Duration(seconds: 15),
  autoConnect: false,
);

    final services = await device.discoverServices();

    BluetoothCharacteristic? heartRateCharacteristic;

    for (final service in services) {
      if (service.uuid == heartRateServiceUuid) {
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid == heartRateMeasurementUuid) {
            heartRateCharacteristic = characteristic;
            break;
          }
        }
      }
    }

    if (heartRateCharacteristic == null) {
      throw Exception("Heart rate characteristic not found on this device.");
    }

    await heartRateCharacteristic.setNotifyValue(true);

    await _heartRateSubscription?.cancel();

    _heartRateSubscription =
        heartRateCharacteristic.onValueReceived.listen((value) async {
      final bpm = _parseHeartRate(value);

      if (bpm > 0) {
        _heartRateController.add(bpm);
        await _saveHeartRateToFirestore(bpm, device);
      }
    });
  }

  int _parseHeartRate(List<int> value) {
    if (value.length < 2) return 0;

    final flags = value[0];
    final is16Bit = (flags & 0x01) != 0;

    if (is16Bit && value.length >= 3) {
      return value[1] | (value[2] << 8);
    }

    return value[1];
  }

  Future<void> _saveHeartRateToFirestore(
    int bpm,
    BluetoothDevice device,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final deviceName = device.platformName.isNotEmpty
        ? device.platformName
        : device.remoteId.toString();

    final data = {
      'type': 'heartRate',
      'value': bpm,
      'unit': 'bpm',
      'source': 'bluetooth',
      'deviceName': deviceName,
      'deviceId': device.remoteId.toString(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('iotReadings')
        .add(data);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('vitals')
        .add(data);
  }

  Future<void> disconnect() async {
    await _heartRateSubscription?.cancel();
    _heartRateSubscription = null;

    final device = connectedDevice;
    connectedDevice = null;

    if (device != null) {
      await device.disconnect();
    }
  }

  void dispose() {
    _heartRateSubscription?.cancel();
    _heartRateController.close();
  }
}