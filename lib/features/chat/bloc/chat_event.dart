import 'package:equatable/equatable.dart';
import 'chat_state.dart';
import '../models/chat_conversation.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class InitChatSystemEvent extends ChatEvent {
  final String userUid;
  final String userName;
  const InitChatSystemEvent({required this.userUid, required this.userName});

  @override
  List<Object?> get props => [userUid, userName];
}

class RoomsUpdatedEvent extends ChatEvent {
  final List<ChatConversation> rooms;
  const RoomsUpdatedEvent(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class OpenChatRoomEvent extends ChatEvent {
  final String astrologerId;
  final String astrologerName;
  final String? astrologerFirebaseUid;
  const OpenChatRoomEvent({
    required this.astrologerId,
    required this.astrologerName,
    this.astrologerFirebaseUid,
  });

  @override
  List<Object?> get props => [astrologerId, astrologerName, astrologerFirebaseUid];
}

class MessagesUpdatedEvent extends ChatEvent {
  final String roomId;
  final List<ChatMessage> messages;
  const MessagesUpdatedEvent({required this.roomId, required this.messages});

  @override
  List<Object?> get props => [roomId, messages];
}

class SendMessageEvent extends ChatEvent {
  final String text;
  final String astrologerId;
  final String astrologerName;

  const SendMessageEvent({
    required this.text,
    required this.astrologerId,
    required this.astrologerName,
  });

  @override
  List<Object?> get props => [text, astrologerId, astrologerName];
}
