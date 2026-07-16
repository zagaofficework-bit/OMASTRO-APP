import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;
  Timer? _heartbeatTimer;

  /// Update online presence in both Firestore and Supabase
  Future<void> setPresence({
    required String firebaseUid,
    required String astrologerId,
    required bool isOnline,
  }) async {
    try {
      // 1. Update Firestore presence
      await _firestore.collection('presence').doc(firebaseUid).set({
        'is_online': isOnline,
        'last_seen': FieldValue.serverTimestamp(),
        'astrologer_id': astrologerId,
      }, SetOptions(merge: true));

      // 2. Heartbeat logic is initiated on Firestore only

      debugPrint('[PresenceService] Updated presence to: $isOnline for astro $astrologerId');

      if (isOnline) {
        _startHeartbeat(firebaseUid, astrologerId);
      } else {
        _stopHeartbeat();
      }
    } catch (e) {
      debugPrint('[PresenceService] Error setting presence: $e');
    }
  }

  void _startHeartbeat(String firebaseUid, String astrologerId) {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        await _firestore.collection('presence').doc(firebaseUid).set({
          'is_online': true,
          'last_seen': FieldValue.serverTimestamp(),
          'astrologer_id': astrologerId,
        }, SetOptions(merge: true));
        debugPrint('[PresenceService] Heartbeat ping sent.');
      } catch (e) {
        debugPrint('[PresenceService] Heartbeat error: $e');
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }
}
