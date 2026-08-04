import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/call/widgets/incoming_call_listener.dart';
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

    // 4. Create distinct notification channels for Android (Calls vs. Chats)
    const AndroidNotificationChannel callChannel = AndroidNotificationChannel(
      'omastro_call_channel',
      'Incoming Calls',
      description: 'Alerts for incoming audio and video calls.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
      'omastro_chat_channel',
      'Chat Messages',
      description: 'Alerts for new chat messages.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(callChannel);
    await androidImplementation?.createNotificationChannel(chatChannel);

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

    // 7. Check if app was launched by tapping a notification when terminated
    final NotificationAppLaunchDetails? launchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchDetails?.notificationResponse?.payload != null) {
      _onNotificationTapped(launchDetails!.notificationResponse!);
    }

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

  void _handleNotificationPayload(Map<String, dynamic> data) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    if (data['type'] == 'call') {
      final String? callId = data['callId'];
      final mode = data['mode'] == 'video' ? 'video' : 'voice';

      if (callId != null && callId.isNotEmpty) {
        try {
          final doc = await FirebaseFirestore.instance.collection('calls').doc(callId).get();
          final callData = doc.data();
          final status = callData?['status']?.toString();

          if (status == 'ringing') {
            // Call is currently ringing — open the Accept / Decline screen!
            IncomingCallOverlay.show(
              context,
              callId: callId,
              callData: callData ?? {
                'callerUid': data['callerId'] ?? '',
                'callerName': data['callerName'] ?? 'Someone',
                'mode': mode,
              },
            );
            return;
          } else if (status == 'accepted') {
            // Call was already accepted — proceed to live call page
            final targetRoute = mode == 'video' ? '/video-call' : '/live-call';
            final extraPayload = {
              'astrologer': {
                'id': data['callerId'] ?? '',
                'name': data['callerName'] ?? 'Someone',
                'firebase_uid': data['callerId'] ?? '',
              },
              'incomingCallId': callId,
            };
            context.push(targetRoute, extra: extraPayload);
            return;
          } else {
            // Call ended or declined
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This call has ended or was declined.')),
            );
            return;
          }
        } catch (e) {
          debugPrint('Error checking call status on notification tap: $e');
        }
      }
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

  final Map<String, DateTime> _recentNotificationCache = {};

  bool _isDuplicate(String key) {
    final now = DateTime.now();
    final lastTime = _recentNotificationCache[key];
    if (lastTime != null && now.difference(lastTime).inSeconds < 3) {
      return true; // Suppress duplicate within 3 seconds
    }
    _recentNotificationCache[key] = now;
    _recentNotificationCache.removeWhere((_, time) => now.difference(time).inSeconds > 10);
    return false;
  }

  Future<void> showChatNotification({
    required String title,
    required String body,
    String? payload,
    int? notificationId,
  }) async {
    if (!_isInitialized) await init();

    final cacheKey = '$title:$body';
    if (_isDuplicate(cacheKey)) {
      debugPrint('[NotificationService] Suppressed duplicate notification: $cacheKey');
      return;
    }

    final id = notificationId ?? cacheKey.hashCode;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'omastro_chat_channel',
      'Chat Messages',
      channelDescription: 'Alerts for new chat messages.',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.message,
      icon: '@mipmap/launcher_icon',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: payload,
    );
  }
}
