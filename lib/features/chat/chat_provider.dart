import 'package:flutter/material.dart';
import 'models/chat_conversation.dart';

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

class ChatProvider extends ChangeNotifier {
  // Pre-fill with Astro Priya's conversation to match initial mockup state
  final List<ChatConversation> _activeConversations = [
    const ChatConversation(
      id: 'chat_priya_01',
      astrologerName: 'Astro Priya',
      lastMessage: 'hi',
      time: '11:05 PM',
      profileImageUrl: 'assets/images/priya.jpg',
    ),
  ];

  final Map<String, List<ChatMessage>> _messages = {
    'chat_priya_01': [
      ChatMessage(text: 'hi', time: '11:05 PM', isMe: true),
    ]
  };

  List<ChatConversation> get activeConversations => _activeConversations;

  List<ChatMessage> getMessagesForChat(String chatId) {
    return _messages[chatId] ?? [];
  }

  void sendMessage(String chatId, String astrologerName, String text) {
    final now = DateTime.now();
    // Simple 12-hour formatting (e.g. 11:05 PM)
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    final newMessage = ChatMessage(text: text, time: timeStr, isMe: true);

    if (_messages.containsKey(chatId)) {
      _messages[chatId]!.add(newMessage);
    } else {
      _messages[chatId] = [newMessage];
    }

    // Update conversation details
    final index = _activeConversations.indexWhere((c) => c.id == chatId);
    final updatedConvo = ChatConversation(
      id: chatId,
      astrologerName: astrologerName,
      lastMessage: text,
      time: timeStr,
      profileImageUrl: _getProfileImageForAstrologer(astrologerName),
    );

    if (index != -1) {
      _activeConversations.removeAt(index);
      _activeConversations.insert(0, updatedConvo); // Move to top
    } else {
      _activeConversations.insert(0, updatedConvo);
    }

    notifyListeners();
  }

  String _getProfileImageForAstrologer(String name) {
    if (name.contains('Meera')) return 'assets/images/meera.jpg';
    if (name.contains('Priya')) return 'assets/images/priya.jpg';
    if (name.contains('Shivam')) return 'assets/images/shivam.jpg';
    if (name.contains('Anand')) return 'assets/images/anand.jpg';
    return 'assets/images/logo.png';
  }
}

final globalChatProvider = ChatProvider();
