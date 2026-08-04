import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirebaseCallRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _astroUid(String id) => 'astro-$id';

  String _roomIdFor(String uidA, String uidB) {
    final list = [uidA, uidB];
    list.sort();
    return list.join('__');
  }

  /// Resolve the astrologer's real Firebase UID dynamically
  Future<String> _resolveTargetFirebaseUid(
      String astrologerId, String? calleeFirebaseUid) async {
    bool isUuid(String str) => str.length == 36 && str.contains('-');

    // 1. If calleeFirebaseUid is already a valid Firebase UID (not a UUID), return it!
    if (calleeFirebaseUid != null &&
        calleeFirebaseUid.isNotEmpty &&
        !isUuid(calleeFirebaseUid)) {
      return calleeFirebaseUid;
    }

    // 2. If astrologerId is a Firebase UID (not a UUID), return it!
    if (astrologerId.isNotEmpty && !isUuid(astrologerId)) {
      return astrologerId;
    }

    final lookupId = isUuid(astrologerId)
        ? astrologerId
        : ((calleeFirebaseUid != null && isUuid(calleeFirebaseUid))
            ? calleeFirebaseUid
            : '');

    // 3. Query Supabase for firebase_uid by astrologer id (UUID)
    if (lookupId.isNotEmpty) {
      try {
        final res = await Supabase.instance.client
            .from('astrologers')
            .select('firebase_uid')
            .eq('id', lookupId)
            .maybeSingle();

        final fetchedUid = res?['firebase_uid']?.toString();
        if (fetchedUid != null && fetchedUid.isNotEmpty) {
          debugPrint(
              '[FirebaseCallRepository] Resolved target firebase_uid from Supabase: $fetchedUid');
          return fetchedUid;
        }
      } catch (e) {
        debugPrint(
            '[FirebaseCallRepository] Supabase target uid lookup error: $e');
      }
    }

    // 4. Query Firestore presence collection for astrologer_id matching lookupId
    if (lookupId.isNotEmpty) {
      try {
        final snap = await _firestore.collection('presence').get();
        for (final doc in snap.docs) {
          final data = doc.data();
          if (data['astrologer_id'] == lookupId || doc.id == lookupId) {
            return doc.id;
          }
        }
      } catch (_) {}
    }

    return (calleeFirebaseUid != null && calleeFirebaseUid.isNotEmpty)
        ? calleeFirebaseUid
        : (astrologerId.isNotEmpty ? astrologerId : _astroUid(astrologerId));
  }

  /// Start a call to the astrologer.
  /// Returns the Firestore document ID for the call record.
  Future<String> startCall({
    required String callerUid,
    required String callerName,
    required String calleeName,
    required String astrologerId,
    String? calleeFirebaseUid,
    required String mode, // 'audio' or 'video'
  }) async {
    String targetUid =
        await _resolveTargetFirebaseUid(astrologerId, calleeFirebaseUid);

    // Self-call prevention: If resolved target equals caller's own UID, override with calleeFirebaseUid
    if (targetUid == callerUid && calleeFirebaseUid != null && calleeFirebaseUid.isNotEmpty && calleeFirebaseUid != callerUid) {
      targetUid = calleeFirebaseUid;
    }

    final String otherUid =
        targetUid.isNotEmpty ? targetUid : _astroUid(astrologerId);

    debugPrint('=== START CALL DEBUG ===');
    debugPrint('calleeName: $calleeName');
    debugPrint('astrologerId: $astrologerId');
    debugPrint('calleeFirebaseUid: $calleeFirebaseUid');
    debugPrint('FINAL otherUid used: $otherUid');
    debugPrint('========================');

    // Keep the Zego room ID stable so it matches the existing chat room thread.
    final roomId = _roomIdFor(callerUid, otherUid);

    debugPrint('[FirebaseCallRepository] Creating $mode call to $otherUid...');

    try {
      final docRef = await _firestore.collection('calls').add({
        'callerUid': callerUid,
        'callerName': callerName,
        'calleeUid': otherUid,
        'calleeName': calleeName,
        'astrologerId': astrologerId,
        'mode': mode,
        'roomId': roomId,
        'status': 'ringing',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final callId = docRef.id;
      debugPrint('[FirebaseCallRepository] Call created with ID: $callId');

      try {
        final chatRoomId = _roomIdFor(callerUid, otherUid);

        final roomRef = _firestore.collection('chats').doc(chatRoomId);
        final roomSnap = await roomRef.get();
        if (!roomSnap.exists) {
          await roomRef.set({
            'members': [callerUid, otherUid],
            'memberNames': {callerUid: callerName, otherUid: calleeName},
            'memberAvatars': {callerUid: '', otherUid: ''},
            'astrologerId': astrologerId,
            'astrologerFirebaseUid': otherUid,
            'createdAt': FieldValue.serverTimestamp(),
            'unread': {callerUid: 0, otherUid: 0},
          });
        }

        // Add the custom call log message
        await roomRef.collection('messages').add({
          'text': '[CALL_LOG]:$mode:ended',
          'senderId': callerUid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update the last message in chat room
        await roomRef.update({
          'lastMessage': mode == 'audio' ? '📞 Voice Call' : '📹 Video Call',
          'lastSenderId': callerUid,
          'lastMessageAt': FieldValue.serverTimestamp(),
        });
      } catch (chatError) {
        debugPrint(
          '[FirebaseCallRepository] Failed to log call in chat: $chatError',
        );
      }

      return callId;
    } catch (e) {
      debugPrint('[FirebaseCallRepository] Failed to create call: $e');
      rethrow;
    }
  }

  /// Resolve the shared room ID for a call document.
  Future<String?> getRoomId(String callId) async {
    try {
      final doc = await _firestore.collection('calls').doc(callId).get();
      final data = doc.data();
      return data?['roomId']?.toString();
    } catch (e) {
      debugPrint(
        '[FirebaseCallRepository] Failed to load roomId for $callId: $e',
      );
      return null;
    }
  }

  /// Mark a call as ended
  Future<void> endCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'status': 'ended',
        'endedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[FirebaseCallRepository] Call $callId ended successfully.');
    } catch (e) {
      debugPrint('[FirebaseCallRepository] Failed to end call: $e');
    }
  }
}
