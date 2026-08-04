import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_conversation.dart';

class FirebaseChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hardcoded fallback map for development in case Supabase has the wrong firebase_uid
  final Map<String, String> _devFirebaseUidMap = {
    'Astro Priya': 'DRBaphzzYdYVcLnPfPAhYHynQn93',
    'Yogini Meera': '4QByl2hM3HZPj2cb0W4mYhXooMo2',
    'Pandit Ramesh': 'bD5luP4IfnbCU1s0EbRCjSGKWWf1',
  };

  String _astroUid(String astrologerId) => 'astro-$astrologerId';

  String _roomIdFor(String uidA, String uidB) {
    final list = [uidA, uidB];
    list.sort();
    return list.join('__');
  }

  /// Ensure a chat room exists between the user and the astrologer
  Future<String> ensureChatRoom({
    required String userUid,
    required String userName,
    required String astrologerId,
    required String astrologerName,
    String? astrologerFirebaseUid,
    String? userAvatar,
    String? astrologerAvatar,
    String? targetOtherUid,
  }) async {
    String clientUid;
    String astroUid;
    String clientName;
    String astroName;
    String clientAvatar;
    String astroAvatar;

    if (targetOtherUid != null &&
        targetOtherUid.isNotEmpty &&
        targetOtherUid != userUid) {
      // Called from AstrologerChatRoomPage: userUid is Astrologer, targetOtherUid is Client
      astroUid = userUid;
      clientUid = targetOtherUid;
      astroName = userName;
      clientName = astrologerName;
      astroAvatar = astrologerAvatar ?? '';
      clientAvatar = userAvatar ?? '';
    } else {
      // Called from ChatRoomPage: userUid is Client, otherUid is Astrologer
      clientUid = userUid;
      astroUid = _devFirebaseUidMap[astrologerName] ??
          ((astrologerFirebaseUid != null &&
                  astrologerFirebaseUid.isNotEmpty &&
                  astrologerFirebaseUid != userUid)
              ? astrologerFirebaseUid
              : _astroUid(astrologerId));
      clientName = userName;
      astroName = astrologerName;
      clientAvatar = userAvatar ?? '';
      astroAvatar = astrologerAvatar ?? '';
    }

    final roomId = _roomIdFor(clientUid, astroUid);
    debugPrint('[FirebaseChatRepository] Ensuring chat room exists: $roomId (clientUid: $clientUid, astroUid: $astroUid)');

    final ref = _firestore.collection('chats').doc(roomId);

    try {
      final snap = await ref.get();
      if (!snap.exists) {
        debugPrint('[FirebaseChatRepository] Chat room does not exist, creating new room...');
        await ref.set({
          'members': [clientUid, astroUid],
          'memberNames': {
            clientUid: clientName,
            astroUid: astroName,
          },
          'memberAvatars': {
            clientUid: clientAvatar,
            astroUid: astroAvatar,
          },
          'astrologerId': astrologerId,
          'astrologerFirebaseUid': astroUid,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessageAt': FieldValue.serverTimestamp(),
          'unread': {
            clientUid: 0,
            astroUid: 0,
          },
        });
        debugPrint('[FirebaseChatRepository] Chat room created successfully.');
      } else {
        debugPrint('[FirebaseChatRepository] Chat room exists, updating names & avatars...');
        final updates = <String, dynamic>{
          'memberNames': {
            clientUid: clientName,
            astroUid: astroName,
          },
        };

        final Map<String, dynamic> avatars = {};
        if (clientAvatar.isNotEmpty) avatars[clientUid] = clientAvatar;
        if (astroAvatar.isNotEmpty) avatars[astroUid] = astroAvatar;
        if (avatars.isNotEmpty) updates['memberAvatars'] = avatars;

        await ref.set(updates, SetOptions(merge: true));

        final data = snap.data();
        if (data != null && data['astrologerFirebaseUid'] == null && astroUid.isNotEmpty) {
          await ref.update({'astrologerFirebaseUid': astroUid});
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
        
        final unreadMap = data['unread'] as Map<String, dynamic>? ?? {};
        final isAstro = userUid == data['astrologerFirebaseUid'];
        final unreadCount = isAstro
            ? ((unreadMap[userUid] ?? unreadMap[astrologerId]) as num?)?.toInt() ?? 0
            : (unreadMap[userUid] as num?)?.toInt() ?? 0;

        return ChatConversation(
          id: astrologerId, // Astrologer's Supabase ID
          astrologerName: astrologerName,
          lastMessage: lastMessage,
          time: timeStr,
          profileImageUrl: profileImageUrl,
          roomId: doc.id, // Keep the firestore roomId
          otherUid: otherUid,
          lastSenderId: lastSenderId,
          unreadCount: unreadCount,
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
        .orderBy('createdAt', descending: true)
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
          imageUrl: data['imageUrl'] as String?,
        );
      }).toList();
    });
  }

  /// Send a message
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
    String? imageUrl,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && imageUrl == null) return;
    
    debugPrint('[FirebaseChatRepository] Sending message to room $roomId: $trimmed, image: $imageUrl');

    try {
      final batch = _firestore.batch();
      
      // 1. Add message
      final msgRef = _firestore.collection('chats').doc(roomId).collection('messages').doc();
      batch.set(msgRef, {
        'text': trimmed,
        'senderId': senderId,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': ?imageUrl,
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

      final displayLastMessage = trimmed.isNotEmpty
          ? trimmed
          : (imageUrl != null ? '📷 Image' : '');

      final updateData = <String, dynamic>{
        'lastMessage': displayLastMessage,
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

  /// Reset the unread count for the given user in a specific room
  Future<void> resetUnreadCount({required String roomId, required String userUid}) async {
    try {
      final ref = _firestore.collection('chats').doc(roomId);
      await ref.update({'unread.$userUid': 0});
      debugPrint('[FirebaseChatRepository] Reset unread count for user $userUid in room $roomId');
    } catch (e) {
      debugPrint('[FirebaseChatRepository] Error resetting unread count: $e');
    }
  }
}

class ChatMessageModel {
  final String id;
  final String text;
  final String senderId;
  final String time;
  final Timestamp? createdAt;
  final String? imageUrl;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.time,
    this.createdAt,
    this.imageUrl,
  });
}
