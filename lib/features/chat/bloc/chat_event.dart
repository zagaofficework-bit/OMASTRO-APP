import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String astrologerName;
  final String text;

  const SendMessageEvent({
    required this.chatId,
    required this.astrologerName,
    required this.text,
  });

  @override
  List<Object> get props => [chatId, astrologerName, text];
}

