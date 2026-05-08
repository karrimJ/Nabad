import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../routes/app_routes.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await FCMService.showLocalNotification(message);
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _requestPermissions();
    await _saveToken();

    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _saveToken();
      }
    });

    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      _handleNavigation(initialMessage.data);
    }
  }

  static Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _saveToken() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final token = await _messaging.getToken();

    if (token == null) return;

    await _firestore.collection('users').doc(user.uid).set(
      {
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> _onTokenRefresh(String token) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set(
      {
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    await showLocalNotification(message);
  }

  static void _onNotificationTap(RemoteMessage message) {
    _handleNavigation(message.data);
  }

  static void _handleNavigation(Map<String, dynamic> data) {
    final navigator = navigatorKey.currentState;

    if (navigator == null) return;

    final type = data['type'];

    switch (type) {
      case 'medication':
        navigator.pushNamed(AppRoutes.medications);
        break;
      case 'sos':
        navigator.pushNamed(AppRoutes.emergency);
        break;
      default:
        break;
    }
  }

  static Future<void> initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;

        if (payload == 'sos') {
          _handleNavigation({'type': 'sos'});
        }

        if (payload == 'medication') {
          _handleNavigation({'type': 'medication'});
        }
      },
    );

    const channel = AndroidNotificationChannel(
      'nabd_channel',
      'Nabd Notifications',
      description: 'Health alerts & reminders',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'nabd_channel',
      'Nabd Notifications',
      channelDescription: 'Health alerts & reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: message.data['type'],
    );
  }

  static Future<void> deleteToken() async {
    final user = _auth.currentUser;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      });
    }

    await _messaging.deleteToken();
  }
}