import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseCallRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hardcoded fallback map for development in case Supabase has the wrong firebase_uid
  final Map<String, String> _devFirebaseUidMap = {
    'Astro Priya': 'DRBaphzzYdYVcLnPfPAhYHynQn93',
    'Yogini Meera': '4QByl2hM3HZPj2cb0W4mYhXooMo2',
    'Pandit Ramesh': 'bD5luP4IfnbCU1s0EbRCjSGKWWf1',
  };

  String _astroUid(String id) => 'astro-$id';

  /// Start a call to the astrologer.
  /// Returns the Firestore document ID which should be used as the Zego Room ID.
  Future<String> startCall({
    required String callerUid,
    required String callerName,
    required String calleeName,
    required String astrologerId,
    String? calleeFirebaseUid,
    required String mode, // 'audio' or 'video'
  }) async {
    // If Supabase didn't provide a firebase_uid, check our hardcoded map, else fallback
    final String otherUid = _devFirebaseUidMap[calleeName] ?? 
        ((calleeFirebaseUid != null && calleeFirebaseUid.isNotEmpty) 
            ? calleeFirebaseUid 
            : _astroUid(astrologerId));

    debugPrint('=== START CALL DEBUG ===');
    debugPrint('calleeName: $calleeName');
    debugPrint('astrologerId: $astrologerId');
    debugPrint('calleeFirebaseUid: $calleeFirebaseUid');
    debugPrint('FINAL otherUid used: $otherUid');
    debugPrint('========================');

    // Generate roomId
    final list = [callerUid, otherUid];
    list.sort();
    final roomId = '${list.join('__')}_${DateTime.now().millisecondsSinceEpoch}';

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
      return callId;
    } catch (e) {
      debugPrint('[FirebaseCallRepository] Failed to create call: $e');
      rethrow;
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
