import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/chat_conversation.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatUpdatedState(
    activeConversations: [
      const ChatConversation(
        id: 'chat_priya_01',
        astrologerName: 'Astro Priya',
        lastMessage: 'hi',
        time: '11:05 PM',
        profileImageUrl: 'assets/images/priya.jpg',
      ),
    ],
    messages: {
      'chat_priya_01': [
        ChatMessage(text: 'hi', time: '11:05 PM', isMe: true),
      ]
    },
  )) {
    on<SendMessageEvent>((event, emit) {
      final currentState = state;
      if (currentState is ChatUpdatedState) {
        final now = DateTime.now();
        final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
        final minute = now.minute.toString().padLeft(2, '0');
        final period = now.hour >= 12 ? 'PM' : 'AM';
        final timeStr = '$hour:$minute $period';

        final newMessage = ChatMessage(text: event.text, time: timeStr, isMe: true);

        // Copy maps and lists to maintain immutability
        final newMessages = Map<String, List<ChatMessage>>.from(currentState.messages);
        if (newMessages.containsKey(event.chatId)) {
          newMessages[event.chatId] = List.from(newMessages[event.chatId]!)..add(newMessage);
        } else {
          newMessages[event.chatId] = [newMessage];
        }

        final newConversations = List<ChatConversation>.from(currentState.activeConversations);
        final index = newConversations.indexWhere((c) => c.id == event.chatId);
        
        final updatedConvo = ChatConversation(
          id: event.chatId,
          astrologerName: event.astrologerName,
          lastMessage: event.text,
          time: timeStr,
          profileImageUrl: _getProfileImageForAstrologer(event.astrologerName),
        );

        if (index != -1) {
          newConversations.removeAt(index);
          newConversations.insert(0, updatedConvo);
        } else {
          newConversations.insert(0, updatedConvo);
        }

        emit(ChatUpdatedState(
          activeConversations: newConversations,
          messages: newMessages,
        ));
      }
    });
  }

  String _getProfileImageForAstrologer(String name) {
    if (name.contains('Meera')) return 'assets/images/meera.jpg';
    if (name.contains('Priya')) return 'assets/images/priya.jpg';
    if (name.contains('Shivam')) return 'assets/images/shivam.jpg';
    if (name.contains('Anand')) return 'assets/images/anand.jpg';
    return 'assets/images/logo.png';
  }
}

