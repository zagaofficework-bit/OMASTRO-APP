import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/chat_conversation.dart';
import '../widgets/chat_tile.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  // 💡 This is your dynamic list mock state.
  // To test the empty state, simply clear this array: []
  final List<ChatConversation> _activeChats = [
    const ChatConversation(
      id: 'chat_priya_01',
      astrologerName: 'Astro Priya',
      lastMessage: 'hi',
      time: '11:05 PM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: const Color(
        0xFFFAF6F0,
      ), // Signature premium cream background tone
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Your conversations with astrologers.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Dynamic List Switch Layer
              Expanded(
                child: _activeChats.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _activeChats.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final chat = _activeChats[index];
                          return ChatTile(
                            conversation: chat,
                            onTap: () {
                              // 👈 Navigates directly inside the active chat room with this astrologer's dataset
                              context.push(
                                '/chat-room',
                                extra: {
                                  'id': chat.id,
                                  'name': chat.astrologerName,
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Clean fallback UI when there are no dynamic records to show yet
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_outlined,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            'No active conversations',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
