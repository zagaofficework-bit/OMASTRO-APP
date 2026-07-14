import 'package:equatable/equatable.dart';
import '../models/chat_conversation.dart';

class ChatMessage {
  final String id;
  final String text;
  final String time;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
  });
}

abstract class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object?> get props => [];
}

class ChatInitialState extends ChatState {}

class ChatUpdatedState extends ChatState {
  final String userUid;
  final String userName;
  final List<ChatConversation> activeConversations;
  final Map<String, List<ChatMessage>> messages; // Keyed by roomId
  final String? activeRoomId; // The room currently open

  const ChatUpdatedState({
    required this.userUid,
    required this.userName,
    required this.activeConversations,
    required this.messages,
    this.activeRoomId,
  });

  int get totalUnreadCount {
    return activeConversations.fold(0, (sum, convo) => sum + convo.unreadCount);
  }

  ChatUpdatedState copyWith({
    String? userUid,
    String? userName,
    List<ChatConversation>? activeConversations,
    Map<String, List<ChatMessage>>? messages,
    String? activeRoomId,
  }) {
    return ChatUpdatedState(
      userUid: userUid ?? this.userUid,
      userName: userName ?? this.userName,
      activeConversations: activeConversations ?? this.activeConversations,
      messages: messages ?? this.messages,
      activeRoomId: activeRoomId ?? this.activeRoomId,
    );
  }

  ChatUpdatedState clearActiveRoom() {
    return ChatUpdatedState(
      userUid: userUid,
      userName: userName,
      activeConversations: activeConversations,
      messages: messages,
      activeRoomId: null,
    );
  }

  @override
  List<Object?> get props => [userUid, userName, activeConversations, messages, activeRoomId];
}
