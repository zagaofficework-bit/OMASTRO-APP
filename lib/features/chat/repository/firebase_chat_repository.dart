import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_conversation.dart';

class FirebaseChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _astroUid(String astrologerId) => 'astro-$astrologerId';

  String _roomIdFor(String uidA, String uidB) {
    final list = [uidA, uidB];
    list.sort();
    return list.join('__');
  }

  // Hardcoded fallback map for development in case Supabase has the wrong firebase_uid
  final Map<String, String> _devFirebaseUidMap = {
    'Astro Priya': 'DRBaphzzYdYVcLnPfPAhYHynQn93', // Real Firebase UID from web console
  };

  /// Ensure a chat room exists between the user and the astrologer
  Future<String> ensureChatRoom({
    required String userUid,
    required String userName,
    required String astrologerId,
    required String astrologerName,
    String? astrologerFirebaseUid,
    String? userAvatar,
    String? astrologerAvatar,
  }) async {
    // 1. Check if we have a hardcoded dev UID for this astrologer
    // 2. Otherwise use the one passed from Supabase
    // 3. Otherwise fallback to the astro- prefix
    final resolvedFirebaseUid = _devFirebaseUidMap[astrologerName] ?? astrologerFirebaseUid;
    
    final otherUid = resolvedFirebaseUid ?? _astroUid(astrologerId);
    final roomId = _roomIdFor(userUid, otherUid);
    debugPrint('[FirebaseChatRepository] Ensuring chat room exists: $roomId (userUid: $userUid, otherUid: $otherUid)');
    
    final ref = _firestore.collection('chats').doc(roomId);

    try {
      final snap = await ref.get();
      if (!snap.exists) {
        debugPrint('[FirebaseChatRepository] Chat room does not exist, creating new room...');
        await ref.set({
          'members': [userUid, otherUid],
          'memberNames': {
            userUid: userName,
            otherUid: astrologerName,
          },
          'memberAvatars': {
            userUid: userAvatar ?? '',
            otherUid: astrologerAvatar ?? '',
          },
          'astrologerId': astrologerId,
          'astrologerFirebaseUid': otherUid,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessageAt': FieldValue.serverTimestamp(),
          'unread': {
            userUid: 0,
            otherUid: 0,
          },
        });
        debugPrint('[FirebaseChatRepository] Chat room created successfully.');
      } else {
        debugPrint('[FirebaseChatRepository] Chat room exists, updating names...');
        // Update names in case they changed
        await ref.set({
          'memberNames': {
            userUid: userName,
            otherUid: astrologerName,
          },
          'memberAvatars': {
            userUid: userAvatar ?? '',
            otherUid: astrologerAvatar ?? '',
          },
        }, SetOptions(merge: true));

        final data = snap.data();
        if (data != null && data['astrologerFirebaseUid'] == null && otherUid.isNotEmpty) {
          debugPrint('[FirebaseChatRepository] Updating missing astrologerFirebaseUid to $otherUid');
          await ref.update({'astrologerFirebaseUid': otherUid});
        }
      }
    } catch (e) {
      debugPrint('[FirebaseChatRepository] Error ensuring chat room: $e');
    }
    return roomId;
  }

  /// Listen to all chat rooms for the current user
  Stream<List<ChatConversation>> listenRooms(String userUid) {
    debugPrint('[FirebaseChatRepository] Listening to rooms for user: $userUid');
    return _firestore
        .collection('chats')
        .where('members', arrayContains: userUid)
        .orderBy('lastMessageAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      debugPrint('[FirebaseChatRepository] Received rooms snapshot with ${snapshot.docs.length} rooms');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final memberNames = data['memberNames'] as Map<String, dynamic>? ?? {};
        final memberAvatars = data['memberAvatars'] as Map<String, dynamic>? ?? {};
        
        // Find the astrologer's name and ID by looking for the member that isn't the userUid
        final members = List<String>.from(data['members'] ?? []);
        final otherUid = members.firstWhere((id) => id != userUid, orElse: () => '');
        final astrologerName = memberNames[otherUid] ?? 'Unknown Astrologer';
        final rawUrl = memberAvatars[otherUid]?.toString();
        final profileImageUrl = (rawUrl != null && rawUrl.isNotEmpty) ? rawUrl : null;
        
        final lastMessage = data['lastMessage'] as String? ?? '';
        final lastMessageAt = data['lastMessageAt'] as Timestamp?;
        final lastSenderId = data['lastSenderId'] as String? ?? '';
        
        // Format time
        String timeStr = '';
        if (lastMessageAt != null) {
          final date = lastMessageAt.toDate();
          final now = DateTime.now();
          if (date.year == now.year && date.month == now.month && date.day == now.day) {
            // Today: show time
            final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
            final minute = date.minute.toString().padLeft(2, '0');
            final period = date.hour >= 12 ? 'PM' : 'AM';
            timeStr = '$hour:$minute $period';
          } else {
            // Not today: show date
            timeStr = '${date.day}/${date.month}';
          }
        }

        // We use astrologerId as the id so that the chat_tile can fetch the real avatar
        final astrologerId = data['astrologerId'] as String? ?? doc.id;

        return ChatConversation(
          id: astrologerId, // Astrologer's Supabase ID
          astrologerName: astrologerName,
          lastMessage: lastMessage,
          time: timeStr,
          profileImageUrl: profileImageUrl,
          roomId: doc.id, // Keep the firestore roomId
          otherUid: otherUid,
          lastSenderId: lastSenderId,
        );
      }).toList();
    });
  }

  /// Listen to messages in a specific chat room
  Stream<List<ChatMessageModel>> listenMessages(String roomId) {
    debugPrint('[FirebaseChatRepository] Listening to messages for room: $roomId');
    return _firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .limit(200)
        .snapshots()
        .map((snapshot) {
      debugPrint('[FirebaseChatRepository] Received messages snapshot for room $roomId with ${snapshot.docs.length} messages');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;
        
        String timeStr = '';
        if (createdAt != null) {
          final date = createdAt.toDate();
          final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
          final minute = date.minute.toString().padLeft(2, '0');
          final period = date.hour >= 12 ? 'PM' : 'AM';
          timeStr = '$hour:$minute $period';
        }

        return ChatMessageModel(
          id: doc.id,
          text: data['text'] as String? ?? '',
          senderId: data['senderId'] as String? ?? '',
          time: timeStr,
          createdAt: createdAt,
        );
      }).toList();
    });
  }

  /// Send a message
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    
    debugPrint('[FirebaseChatRepository] Sending message to room $roomId: $trimmed');

    try {
      final batch = _firestore.batch();
      
      // 1. Add message
      final msgRef = _firestore.collection('chats').doc(roomId).collection('messages').doc();
      batch.set(msgRef, {
        'text': trimmed,
        'senderId': senderId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Update chat room
      final roomRef = _firestore.collection('chats').doc(roomId);
      
      // Get unread count first
      final roomSnap = await roomRef.get();
      int currentUnread = 0;
      String otherUid = '';
      if (roomSnap.exists) {
        final data = roomSnap.data();
        final members = List<String>.from(data?['members'] ?? []);
        otherUid = members.firstWhere((id) => id != senderId, orElse: () => '');
        final unreadMap = data?['unread'] as Map<String, dynamic>? ?? {};
        currentUnread = (unreadMap[otherUid] as num?)?.toInt() ?? 0;
      }

      final updateData = <String, dynamic>{
        'lastMessage': trimmed,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
      };

      if (otherUid.isNotEmpty) {
        updateData['unread.$otherUid'] = currentUnread + 1;
      }

      batch.update(roomRef, updateData);

      await batch.commit();
      debugPrint('[FirebaseChatRepository] Message sent and batch committed successfully!');
    } catch (e) {
      debugPrint('[FirebaseChatRepository] Error sending message: $e');
    }
  }
}

class ChatMessageModel {
  final String id;
  final String text;
  final String senderId;
  final String time;
  final Timestamp? createdAt;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.time,
    this.createdAt,
  });
}
