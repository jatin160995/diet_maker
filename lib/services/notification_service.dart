import 'dart:io';
import 'package:diet_maker/services/storage_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background message handler — MUST be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    // Request permissions (iOS + Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Setup local notifications for foreground display
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    await _localNotifications.initialize(
  settings: const InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  ),
);

    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');
    if (token != null) {
      await StorageService.saveFcmToken(token);
      print('FCM Token saved: $token');
    }

    // Handle token refresh (e.g. on reinstall or token rotation)
    _messaging.onTokenRefresh.listen((newToken) async {
      await StorageService.saveFcmToken(newToken);
      print('FCM Token refreshed: $newToken');
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Background tap handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped (background): ${message.data}');
    });

    // Terminated state tap handler
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print(
        'App opened from terminated via notification: ${initialMessage.data}',
      );
    }

    // iOS foreground presentation
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
  id: notification.hashCode,
  title: notification.title,
  body: notification.body,
  notificationDetails: NotificationDetails(
    android: AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  ),
);
  }
}
