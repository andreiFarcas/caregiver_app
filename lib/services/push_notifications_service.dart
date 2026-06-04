import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:caregiver_app/services/api_service.dart';
import 'package:caregiver_app/core/services/app_config_service.dart';
import 'package:caregiver_app/firebase_options.dart';

// Background messaging handler
// Must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized before handling background notifications
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

class PushNotificationsService {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Firebase initialization error: $e");
      }
    }

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions (primarily for iOS and newer Androids)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Initialize Local Notifications for Foreground Alerts
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

    await _localNotificationsPlugin.initialize(settings: initSettings);

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // Create a high importance channel for Android so it pops up on screen
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'emergency_alerts', // id
      'Emergency Alerts', // title
      description: 'Critical alerts for falls and panics.', // description
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Tell Firebase to show foreground notifications natively on iOS
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Fetch the FCM token for this device
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        print("FCM Token: $token");
        // Register token with our FastAPI backend
        final appId = await AppConfigService.getAppId();
        await ApiService.registerFCMToken(appId, token);
      }
    } catch (e) {
      print("Failed to get FCM token: $e");
    }

    // Update server automatically if the token ever refreshes
    messaging.onTokenRefresh
        .listen((newToken) async {
          print("FCM Token Refreshed: $newToken");
          final appId = await AppConfigService.getAppId();
          await ApiService.registerFCMToken(appId, newToken);
        })
        .onError((err) {
          print("Error during token refresh: $err");
        });
  }

  void setupMessageHandlers() {
    // 1. Background / Terminated state
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Foreground state (when app is open and visible)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Show Local Notification manually because Android blocks FCM UI pushes while app is open
        _localNotificationsPlugin.show(
          id: message.hashCode,
          title: message.notification?.title,
          body: message.notification?.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'emergency_alerts',
              'Emergency Alerts',
              channelDescription: 'Critical alerts for falls and panics.',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              color: Color(0xFFFF0000), // Red color for emergency
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }
    });
  }
}
