import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../app/route.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background/terminated message received: ${message.notification?.title}');
  // System automatically displays notification banner from FCM payload using high_importance_channel.
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // 1. Request FCM permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Set foreground presentation options (alert, badge, sound)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Local Notifications setup
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 4. Create high importance notification channel for Android
    const AndroidNotificationChannel highImportanceChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important incoming call and chat notifications.',
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highImportanceChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // 5. Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground notification received: ${message.notification?.title}');
      final notification = message.notification;
      if (notification != null && !kIsWeb) {
        showChatNotification(
          title: notification.title ?? 'OmAstro Notification',
          body: notification.body ?? '',
          payload: jsonEncode(message.data),
        );
      }
    });

    // 6. Listen for notification taps when app is in background/opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Notification tapped: ${message.data}');
      _handleNotificationPayload(message.data);
    });

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local Notification tapped with payload: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final data = jsonDecode(response.payload!);
        if (data is Map<String, dynamic>) {
          _handleNotificationPayload(data);
        }
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  void _handleNotificationPayload(Map<String, dynamic> data) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    if (data['type'] == 'call') {
      final mode = data['mode'] == 'video' ? 'video' : 'voice';
      final targetRoute = mode == 'video' ? '/video-call' : '/live-call';
      
      final extraPayload = {
        'astrologer': {
          'id': data['callerId'] ?? '',
          'name': data['callerName'] ?? 'Someone',
        },
        'incomingCallId': data['callId'],
      };
      
      context.push(targetRoute, extra: extraPayload);
    } else if (data.containsKey('id') && data.containsKey('name')) {
      final authState = context.read<AuthBloc>().state;
      final isAstrologer = authState is AuthenticatedAsAstrologer ||
          authState is AstrologerOnboardingRequired;

      final targetRoute = isAstrologer ? '/astrologer-chat-room' : '/chat-room';

      final extraPayload = {
        'id': data['id'],
        'name': data['name'],
        'otherUid': data['otherUid'] ?? data['id'],
        'avatarUrl': data['avatarUrl'] ?? '',
      };

      context.push(targetRoute, extra: extraPayload);
    } else if (data['type'] == 'astrologer_online') {
      final astroId = data['astrologer_id']?.toString() ?? '';
      if (astroId.isNotEmpty) {
        context.push('/astrologer-profile', extra: {'id': astroId});
      }
    }
  }

  Future<void> showChatNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await init();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important incoming call and chat notifications.',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: payload,
    );
  }
}
