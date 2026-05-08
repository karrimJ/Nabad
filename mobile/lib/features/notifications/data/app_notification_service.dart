import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_notification_model.dart';

class AppNotificationService {
  AppNotificationService({
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

  CollectionReference<Map<String, dynamic>> get _notificationsRef {
    return _firestore.collection('users').doc(_uid).collection('notifications');
  }

  Stream<List<AppNotificationModel>> watchNotifications() {
    return _notificationsRef.snapshots().map((snapshot) {
      final notifications = snapshot.docs
          .map(AppNotificationModel.fromFirestore)
          .toList();

      notifications.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        return bDate.compareTo(aDate);
      });

      return notifications;
    });
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required String type,
    String? route,
    String? relatedId,
  }) async {
    if (title.trim().isEmpty) {
      throw Exception('Notification title is required');
    }

    if (message.trim().isEmpty) {
      throw Exception('Notification message is required');
    }

    await _notificationsRef.add(
      AppNotificationModel.createMap(
        title: title,
        message: message,
        type: type,
        route: route,
        relatedId: relatedId,
      ),
    );
  }

  Future<void> markAsRead(String notificationId) async {
    if (notificationId.trim().isEmpty) return;

    await _notificationsRef.doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearAll() async {
    final snapshot = await _notificationsRef.get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}