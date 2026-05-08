import 'package:cloud_firestore/cloud_firestore.dart';

class NearbyHospital {
  const NearbyHospital({
    required this.id,
    required this.name,
    required this.distanceKm,
    this.phoneNumber,
    this.location,
  });

  final String id;
  final String name;
  final double distanceKm;
  final String? phoneNumber;
  final GeoPoint? location;

  factory NearbyHospital.fromFirestore({
    required QueryDocumentSnapshot<Map<String, dynamic>> doc,
    required double distanceMeters,
  }) {
    final data = doc.data();

    final rawName = data['name'];
    final rawPhone = data['phoneNumber'];
    final rawLocation = data['location'];

    return NearbyHospital(
      id: doc.id,
      name: rawName is String && rawName.trim().isNotEmpty
          ? rawName.trim()
          : 'Unknown Hospital',
      phoneNumber: rawPhone is String && rawPhone.trim().isNotEmpty
          ? rawPhone.trim()
          : null,
      location: rawLocation is GeoPoint ? rawLocation : null,
      distanceKm: distanceMeters / 1000,
    );
  }
}

class SosAlertModel {
  const SosAlertModel({
    required this.latitude,
    required this.longitude,
    required this.mapsLink,
    required this.address,
    this.nearestHospital,
  });

  final double latitude;
  final double longitude;
  final String mapsLink;
  final String address;
  final NearbyHospital? nearestHospital;

  Map<String, dynamic> toCreateMap() {
    return {
      'location': GeoPoint(latitude, longitude),
      'latitude': latitude,
      'longitude': longitude,
      'mapsLink': mapsLink,
      'address': address,
      'nearestHospital': nearestHospital?.name ?? 'Unknown',
      'nearestHospitalPhone': nearestHospital?.phoneNumber,
      'nearestHospitalDistanceKm': nearestHospital?.distanceKm,
      'status': 'active',
      'messageSent': false,
      'source': 'mobile',
      'timestamp': FieldValue.serverTimestamp(),
      'triggeredAt': FieldValue.serverTimestamp(),
    };
  }
}