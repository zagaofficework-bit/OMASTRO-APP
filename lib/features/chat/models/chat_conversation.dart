class ChatConversation {
  final String id;
  final String astrologerName;
  final String lastMessage;
  final String time;
  final String? profileImageUrl; // Fallback to initials if null

  const ChatConversation({
    required this.id,
    required this.astrologerName,
    required this.lastMessage,
    required this.time,
    this.profileImageUrl,
  });
}