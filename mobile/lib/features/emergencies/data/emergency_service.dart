import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'sos_alert_model.dart';

typedef SosStatusCallback = void Function(String message);

class SosAlertResult {
  const SosAlertResult({
    required this.sosId,
    required this.position,
    required this.mapsLink,
    this.nearestHospital,
  });

  final String sosId;
  final Position position;
  final String mapsLink;
  final NearbyHospital? nearestHospital;
}

class EmergencyService {
  EmergencyService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _sosLogsRef {
    return _firestore.collection('users').doc(_uid).collection('sosLogs');
  }

  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Please enable location services');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Enable it from app settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<NearbyHospital?> findNearestHospital(Position userPosition) async {
    final query = await _firestore
        .collection('services')
        .where('type', isEqualTo: 'Hospital')
        .where('isEmergencyAvailable', isEqualTo: true)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    NearbyHospital? nearestHospital;
    double nearestDistanceMeters = double.infinity;

    for (final doc in query.docs) {
      final data = doc.data();
      final rawLocation = data['location'];

      if (rawLocation is! GeoPoint) {
        continue;
      }

      final distanceMeters = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        rawLocation.latitude,
        rawLocation.longitude,
      );

      if (distanceMeters < nearestDistanceMeters) {
        nearestDistanceMeters = distanceMeters;
        nearestHospital = NearbyHospital.fromFirestore(
          doc: doc,
          distanceMeters: distanceMeters,
        );
      }
    }

    return nearestHospital;
  }

  Future<SosAlertResult> triggerSOS({
    SosStatusCallback? onStatus,
  }) async {
    onStatus?.call('Getting location...');

    final position = await getCurrentPosition();

    final mapsLink =
        'https://maps.google.com/?q=${position.latitude},${position.longitude}';

    onStatus?.call('Finding nearest hospital...');

    final nearestHospital = await findNearestHospital(position);

    onStatus?.call('Saving SOS alert...');

    final sosAlert = SosAlertModel(
      latitude: position.latitude,
      longitude: position.longitude,
      mapsLink: mapsLink,
      address: mapsLink,
      nearestHospital: nearestHospital,
    );

    final docRef = await _sosLogsRef.add(sosAlert.toCreateMap());

    return SosAlertResult(
      sosId: docRef.id,
      position: position,
      mapsLink: mapsLink,
      nearestHospital: nearestHospital,
    );
  }

  Future<void> callNumber(String number) async {
    final cleanedNumber = number.trim();

    if (cleanedNumber.isEmpty) {
      throw Exception('Phone number is missing');
    }

    final uri = Uri.parse('tel:$cleanedNumber');

    if (!await canLaunchUrl(uri)) {
      throw Exception('Could not open phone app');
    }

    await launchUrl(uri);
  }

  Future<void> sendEmergencySMS() async {
    final position = await getCurrentPosition();

    final mapsLink =
        'https://maps.google.com/?q=${position.latitude},${position.longitude}';

    final body = Uri.encodeComponent(
      'EMERGENCY! I need help.\nMy location: $mapsLink',
    );

    final uri = Uri.parse('sms:?body=$body');

    if (!await canLaunchUrl(uri)) {
      throw Exception('Could not open SMS app');
    }

    await launchUrl(uri);
  }
}