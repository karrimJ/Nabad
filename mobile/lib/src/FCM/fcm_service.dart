import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await FCMService.showLocalNotification(message);
}

class FCMService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> initialize() async {
    await _requestPermissions();
    await _saveToken();
    _messaging.onTokenRefresh.listen(_onTokenRefresh);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
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
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await _firestore.collection('users').doc(uid).update({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> _onTokenRefresh(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    await showLocalNotification(message);
  }

  static void _onNotificationTap(RemoteMessage message) {
    _handleNavigation(message.data);
  }

  static void _handleNavigation(Map<String, dynamic> data) {
    final type = data['type'];
    final context = navigatorKey.currentContext;
    if (context == null) return;

    switch (type) {
      case 'sos':
        // Navigator.pushNamed(context, '/sos');
        break;
      case 'appointment':
        // Navigator.pushNamed(context, '/appointments');
        break;
      case 'medication':
        // Navigator.pushNamed(context, '/medications');
        break;
      default:
        // Navigator.pushNamed(context, '/notifications');
        break;
    }
  }

  static Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'nabd_high_importance',
      'Nabd Notifications',
      description: 'Nabd health and emergency notifications',
      importance: Importance.high,
      playSound: true,
    );

flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'nabd_high_importance',
      'Nabd Notifications',
      channelDescription: 'Nabd health and emergency notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['type'],
    );
  }

  static Future<void> deleteToken() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': FieldValue.delete(),
      });
    }
    await _messaging.deleteToken();
  }
}