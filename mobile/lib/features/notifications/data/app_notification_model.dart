import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.createdAt,
    this.route,
    this.relatedId,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;
  final String? route;
  final String? relatedId;

  factory AppNotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return AppNotificationModel(
      id: doc.id,
      title: _readString(data, 'title', fallback: 'Notification'),
      message: _readString(data, 'message', fallback: ''),
      type: _readString(data, 'type', fallback: 'General'),
      isRead: data['isRead'] == true,
      route: _readNullableString(data, 'route'),
      relatedId: _readNullableString(data, 'relatedId'),
      createdAt: _readDate(data, 'createdAt'),
    );
  }

  static Map<String, dynamic> createMap({
    required String title,
    required String message,
    required String type,
    String? route,
    String? relatedId,
  }) {
    return {
      'title': title.trim(),
      'message': message.trim(),
      'type': type.trim(),
      'route': _normalizeNullable(route),
      'relatedId': _normalizeNullable(relatedId),
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    required String fallback,
  }) {
    final value = data[key];

    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return fallback;
  }

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];

    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return null;
  }

  static DateTime? _readDate(Map<String, dynamic> data, String key) {
    final value = data[key];

    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }

  static String? _normalizeNullable(String? value) {
    if (value == null) return null;

    final trimmed = value.trim();

    if (trimmed.isEmpty) return null;

    return trimmed;
  }
}