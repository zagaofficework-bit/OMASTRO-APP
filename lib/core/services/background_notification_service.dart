import 'dart:async';
import 'dart:convert';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

// Initialize the persistent background service (called once at app startup in main)
Future<void> initBackgroundNotificationService() async {
  final service = FlutterBackgroundService();

  // Create channel for persistent service notification
  const AndroidNotificationChannel serviceChannel = AndroidNotificationChannel(
    'omastro_bg_service',
    'OmAstro Background Service',
    description: 'Keeps call and chat notifications active',
    importance: Importance.min, // Low importance so it runs quietly
  );

  final localNotifications = FlutterLocalNotificationsPlugin();
  await localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(serviceChannel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onServiceStart,
      autoStart: true, // Auto starts/restarts when app is killed/booted
      isForegroundMode: true,
      notificationChannelId: 'omastro_bg_service',
      initialNotificationTitle: 'OmAstro Live Sync',
      initialNotificationContent: 'Active in background...',
      foregroundServiceNotificationId: 999,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onServiceStart,
    ),
  );

  await service.startService();
}

// Runs in a separate isolate (even when app is terminated)
@pragma('vm:entry-point')
Future<void> onServiceStart(ServiceInstance service) async {
  // Initialize Firebase inside the background isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final localNotifications = FlutterLocalNotificationsPlugin();
  await localNotifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    ),
  );

  final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
  if (currentUid == null || currentUid.isEmpty) {
    debugPrint('[BackgroundService] No active user logged in. Standing by...');
  } else {
    debugPrint('[BackgroundService] Logged in user: $currentUid. Initializing Firestore listeners...');
    _setupFirestoreListeners(currentUid, localNotifications);
  }

  // Also listen for auth changes dynamically in case the user logs in/out in the main thread
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      debugPrint('[BackgroundService] Auth state updated: User logged in: ${user.uid}');
      _setupFirestoreListeners(user.uid, localNotifications);
    } else {
      debugPrint('[BackgroundService] Auth state updated: User logged out.');
    }
  });

  // Keep the service alive with a periodic ping
  Timer.periodic(const Duration(seconds: 30), (_) {
    service.invoke('ping');
  });
}

// Global subscriptions references to prevent duplicate listeners
StreamSubscription<QuerySnapshot>? _callSubscription;
StreamSubscription<QuerySnapshot>? _chatSubscription;
final Set<String> _processedCallsCache = {};
final Set<String> _processedMessagesCache = {};

void _setupFirestoreListeners(String currentUid, FlutterLocalNotificationsPlugin localNotifications) {
  // Cancel previous listeners if they exist
  _callSubscription?.cancel();
  _chatSubscription?.cancel();

  final startTime = DateTime.now();

  // 1. Listen for incoming calls (status: ringing)
  _callSubscription = FirebaseFirestore.instance
      .collection('calls')
      .where('calleeUid', isEqualTo: currentUid)
      .where('status', isEqualTo: 'ringing')
      .snapshots()
      .listen((snapshot) {
    for (final change in snapshot.docChanges) {
      if (change.type != DocumentChangeType.added) continue;
      // Skip pending local writes (wait for server timestamp confirmation)
      if (change.doc.metadata.hasPendingWrites) continue;

      if (_processedCallsCache.contains(change.doc.id)) continue;
      _processedCallsCache.add(change.doc.id);

      final data = change.doc.data();
      if (data == null) continue;

      // Skip old calls from before service started
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      if (createdAt == null || createdAt.isBefore(startTime)) continue;

      final callerName = data['callerName'] ?? 'Someone';
      final mode = data['mode'] == 'video' ? 'Video' : 'Voice';

      final payload = jsonEncode({
        'type': 'call',
        'mode': data['mode'] == 'video' ? 'video' : 'voice',
        'callerId': data['callerUid'] ?? '',
        'callerName': callerName,
        'callId': change.doc.id,
      });

      localNotifications.show(
        id: change.doc.id.hashCode,
        title: '📞 Incoming $mode Call',
        body: '$callerName is calling you...',
        payload: payload,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'omastro_call_channel',
            'Incoming Calls',
            channelDescription: 'Alerts for incoming audio and video calls.',
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.call,
            fullScreenIntent: true,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
      );
    }
  });

  // 2. Listen for incoming messages in chats
  _chatSubscription = FirebaseFirestore.instance
      .collection('chats')
      .where('members', arrayContains: currentUid)
      .snapshots()
      .listen((snapshot) {
    for (final change in snapshot.docChanges) {
      // We check modified or added documents to see if a new message was sent
      if (change.type == DocumentChangeType.removed) continue;
      // Skip pending local writes (wait for server timestamp confirmation)
      if (change.doc.metadata.hasPendingWrites) continue;

      final data = change.doc.data();
      if (data == null) continue;

      final lastSenderId = data['lastSenderId']?.toString() ?? '';
      if (lastSenderId == currentUid || lastSenderId.isEmpty) continue;

      final lastMessageAt = (data['lastMessageAt'] as Timestamp?)?.toDate();
      if (lastMessageAt == null || lastMessageAt.isBefore(startTime)) continue;

      final cacheKey = '${change.doc.id}_${lastMessageAt.millisecondsSinceEpoch}';
      if (_processedMessagesCache.contains(cacheKey)) continue;
      _processedMessagesCache.add(cacheKey);

      final lastMessage = data['lastMessage']?.toString() ?? '';
      if (lastMessage.isEmpty) continue;

      // Fetch sender name if possible from names mapping
      final memberNames = data['memberNames'] as Map<String, dynamic>? ?? {};
      final senderName = memberNames[lastSenderId]?.toString() ?? 'New Message';

      final payload = jsonEncode({
        'id': lastSenderId,
        'name': senderName,
        'otherUid': lastSenderId,
        'avatarUrl': '',
      });

      localNotifications.show(
        id: change.doc.id.hashCode,
        title: '💬 $senderName',
        body: lastMessage,
        payload: payload,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'omastro_chat_channel',
            'Chat Messages',
            channelDescription: 'Alerts for new chat messages.',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.message,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
      );
    }
  });
}
