import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';
import '../router.dart';
import 'api_client.dart';

// Must be a top-level function — FCM requires it for background message handling.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

const _androidChannelId = 'mentorx_notifications';
const _androidChannelName = 'MentorX Notifications';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init(String userId) async {
    if (_initialized) return;

    // Register background handler before anything else.
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Request permission (required on iOS; Android 13+ shows a dialog).
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set up Android notification channel for local notifications.
    const androidChannel = AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      importance: Importance.high,
      playSound: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Initialize flutter_local_notifications.
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Tap on a local (foreground) notification — parse payload and route.
        final payload = details.payload;
        if (payload != null) _routeFromPayload(payload);
      },
    );

    // Get and store FCM token.
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);

    // Refresh token handler.
    _messaging.onTokenRefresh.listen(_saveToken);

    // Foreground messages — FCM won't show these automatically; display locally.
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // Background tap (app was in background, user tapped notification).
    FirebaseMessaging.onMessageOpenedApp.listen(_routeFromMessage);

    // Terminated tap (app was closed, user tapped notification to launch it).
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _routeFromMessage(initial);

    _initialized = true;
  }

  Future<void> dispose() async {
    try {
      await ApiClient.instance.delete('/auth/fcm-token');
    } catch (_) {
      // Best-effort — don't block logout.
    }
    _initialized = false;
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<void> _saveToken(String token) async {
    try {
      await ApiClient.instance.post('/auth/fcm-token', body: {'token': token});
      debugPrint('[NotificationService] FCM token saved to backend ✓');
    } catch (e) {
      debugPrint('[NotificationService] Failed to save FCM token: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final type = message.data['type'] as String?;
    final id = message.data['id'] as String?;
    final payload = (type != null && id != null) ? '$type:$id' : null;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      payload: payload,
    );
  }

  void _routeFromMessage(RemoteMessage message) {
    final type = message.data['type'] as String?;
    final id = message.data['id'] as String?;
    _navigate(type, id);
  }

  void _routeFromPayload(String payload) {
    // payload format: "type:id"  e.g. "post:abc-123"
    final parts = payload.split(':');
    final type = parts.isNotEmpty ? parts[0] : null;
    final id = parts.length > 1 ? parts.sublist(1).join(':') : null;
    _navigate(type, id);
  }

  void _navigate(String? type, String? id) {
    switch (type) {
      case 'post':
        if (id != null) appRouter.go('/student/posts/$id');
      case 'chat':
        if (id != null) appRouter.go('/chat/$id');
      case 'attendance':
        appRouter.go('/student/attendance');
    }
  }
}
