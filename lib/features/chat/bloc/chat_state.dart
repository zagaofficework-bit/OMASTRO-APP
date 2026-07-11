import 'package:equatable/equatable.dart';
import '../models/chat_conversation.dart';

// Import ChatMessage class from the former provider or create a new file for it.
// I will just put it here for simplicity or create a models/chat_message.dart.
// Let's create models/chat_message.dart first or just define it here.
// I will just define it in models/chat_message.dart later if needed. For now I will define it in the same file to keep it simple, or better yet, I should check if models/chat_conversation.dart exists. It does.
// Let's put ChatMessage in models/chat_message.dart. Let's do that in a separate step.
// For now, I will use a custom ChatMessage class in chat_state.dart
class ChatMessage {
  final String text;
  final String time;
  final bool isMe;

  ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
  });
}

abstract class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object> get props => [];
}

class ChatUpdatedState extends ChatState {
  final List<ChatConversation> activeConversations;
  final Map<String, List<ChatMessage>> messages;

  const ChatUpdatedState({
    required this.activeConversations,
    required this.messages,
  });

  @override
  List<Object> get props => [activeConversations, messages];
}

