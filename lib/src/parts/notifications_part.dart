part of layerx_generator;

// ========================= NOTIFICATIONS =========================

extension _NotificationsPart on LayerXGenerator {
  Future<void> _createNotificationFiles(String appDirPath) async {
    final notifDir =
    Directory(path.join(appDirPath, 'services', 'notifications'));
    await notifDir.create(recursive: true);

    await File(path.join(notifDir.path, 'notification_permissions.dart'))
        .writeAsString(_notificationPermissionsContent());

    await File(path.join(notifDir.path, 'notification_service.dart'))
        .writeAsString(_notificationServiceContent());

    await File(path.join(notifDir.path, 'server_key.dart'))
        .writeAsString(_serverKeyContent());

    stdout.writeln('✅ Created notification files in services/notifications/');
  }

  // ========================= FILE CONTENTS =========================

  String _notificationPermissionsContent() => r'''
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissions {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('✅ User granted notification permission');

      // ✅ Get token after permission
      String? token = await messaging.getToken();
      log('✅ FCM Token: $token');

      Get.snackbar("Notification", "Permission granted");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      log('🟡 User granted provisional permission');
      Get.snackbar("Notification", "Provisional permission granted");
    } else {
      log('❌ User declined notification permission');
      Get.snackbar("Notification", "Permission denied");
    }
  }

  Future<bool> isNotificationPermissionGranted() async {
    return Permission.notification.isGranted;
  }

  Future<String?> getDeviceToken() async {
    try {
      String? token = await messaging.getToken();
      log("✅ FCM Token: $token");
      return token;
    } catch (e) {
      log("❌ Error getting device token: $e");
      return null;
    }
  }
}
''';

  String _notificationServiceContent() => r'''
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_permissions.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// ✅ Call this from main() after Firebase.initializeApp()
  static Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // ✅ REQUIRED FOR TIMEZONE SUPPORT
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // ✅ Initialize Local Notifications
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("📌 Local notification clicked: ${response.payload}");
      },
    );

    // ✅ Request Notification Permission
    await NotificationPermissions().requestNotificationPermission();

    // ✅ Foreground Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("📩 Foreground Message: ${message.notification?.title}");
      showNotification(message);
    });

    // ✅ When app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("📌 Push notification clicked: ${message.notification?.title}");
    });

    // ✅ Optional: print token
    final token = await _firebaseMessaging.getToken();
    log("✅ FCM Token: $token");
  }

  /// ✅ IMPORTANT:
  /// Background handler MUST be top-level in real apps.
  /// This is kept here because generator writes files only.
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    log("📩 Background Message: ${message.notification?.title}");
  }

  // ✅ Show Notification
  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'layerx_channel',
      'LayerX Notifications',
      channelDescription: 'LayerX push notifications channel',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? "No Title",
      message.notification?.body ?? "No Body",
      notificationDetails,
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }

  // ✅ Schedule Notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'layerx_channel',
          'LayerX Notifications',
          channelDescription: 'LayerX push notifications channel',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
''';

  String _serverKeyContent() => r'''
import 'dart:developer';

import 'package:googleapis_auth/auth_io.dart';
import 'package:logger/logger.dart';

class ServerKeyService {
  final logger = Logger();
  String? serverKey;

  /// ✅ NOTE:
  /// This returns an OAuth access token, not the legacy "server key".
  /// For FCM HTTP v1, you use this access token as Bearer token.
  Future<String?> getServiceKey() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    // ✅ TODO:
    // Paste your Firebase service account JSON here.
    // Never commit it to git. Keep it in env/secure store in real projects.
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        // "type": "service_account",
        // "project_id": "...",
        // "private_key_id": "...",
        // "private_key": "-----BEGIN PRIVATE KEY-----\\n...\\n-----END PRIVATE KEY-----\\n",
        // "client_email": "...",
        // "client_id": "...",
        // ...
      }),
      scopes,
    );

    serverKey = client.credentials.accessToken.data;
    log('✅ FCM Access Token: $serverKey');
    return serverKey;
  }
}
''';
}
