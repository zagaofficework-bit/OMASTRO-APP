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

  /// Update online presence in both Firestore and Supabase, saving last_online_state
  Future<void> setPresence({
    required String firebaseUid,
    required String astrologerId,
    required bool isOnline,
  }) async {
    try {
      final nowIso = DateTime.now().toIso8601String();
      final isUuid = astrologerId.length == 36 && astrologerId.contains('-');

      final presencePayload = {
        'is_online': isOnline,
        'isOnline': isOnline,
        'last_seen': FieldValue.serverTimestamp(),
        'last_online_state': isOnline,
        'astrologer_id': astrologerId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 1. Update Firestore presence and astrologers collections
      if (firebaseUid.isNotEmpty) {
        await _firestore
            .collection('presence')
            .doc(firebaseUid)
            .set(presencePayload, SetOptions(merge: true));

        await _firestore
            .collection('astrologers')
            .doc(firebaseUid)
            .set(presencePayload, SetOptions(merge: true));
      }

      if (astrologerId.isNotEmpty && astrologerId != firebaseUid) {
        await _firestore
            .collection('presence')
            .doc(astrologerId)
            .set(presencePayload, SetOptions(merge: true));

        await _firestore
            .collection('astrologers')
            .doc(astrologerId)
            .set(presencePayload, SetOptions(merge: true));
      }

      // 2. Update Supabase astrologers table safely
      if (astrologerId.isNotEmpty) {
        final col = isUuid ? 'id' : 'firebase_uid';
        try {
          await _supabase
              .from('astrologers')
              .update({'is_online': isOnline, 'last_seen': nowIso})
              .eq(col, astrologerId);
        } catch (_) {
          try {
            await _supabase
                .from('astrologers')
                .update({'is_online': isOnline})
                .eq(col, astrologerId);
          } catch (e) {
            debugPrint('[PresenceService] Supabase update error ($col): $e');
          }
        }
      }

      if (firebaseUid.isNotEmpty) {
        try {
          await _supabase
              .from('astrologers')
              .update({'is_online': isOnline, 'last_seen': nowIso})
              .eq('firebase_uid', firebaseUid);
        } catch (_) {
          try {
            await _supabase
                .from('astrologers')
                .update({'is_online': isOnline})
                .eq('firebase_uid', firebaseUid);
          } catch (e) {
            debugPrint(
              '[PresenceService] Supabase update error (firebase_uid): $e',
            );
          }
        }
      }

      debugPrint(
        '[PresenceService] Synced presence to: $isOnline for astro $astrologerId in Firebase & Supabase',
      );

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
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      try {
        final nowIso = DateTime.now().toIso8601String();
        final presencePayload = {
          'is_online': true,
          'isOnline': true,
          'last_seen': FieldValue.serverTimestamp(),
          'last_online_state': true,
          'astrologer_id': astrologerId,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (firebaseUid.isNotEmpty) {
          await _firestore
              .collection('presence')
              .doc(firebaseUid)
              .set(presencePayload, SetOptions(merge: true));
        }

        if (astrologerId.isNotEmpty) {
          final isUuid =
              astrologerId.length == 36 && astrologerId.contains('-');
          final col = isUuid ? 'id' : 'firebase_uid';
          try {
            await _supabase
                .from('astrologers')
                .update({'is_online': true, 'last_seen': nowIso})
                .eq(col, astrologerId);
          } catch (_) {
            try {
              await _supabase
                  .from('astrologers')
                  .update({'is_online': true})
                  .eq(col, astrologerId);
            } catch (_) {}
          }
        }
        debugPrint(
          '[PresenceService] Heartbeat ping sent (Firebase & Supabase).',
        );
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
