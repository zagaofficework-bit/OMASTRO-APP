import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/chat_tile.dart';

import '../chat_provider.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: globalChatProvider,
      builder: (context, _) {
        final activeChats = globalChatProvider.activeConversations;

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
                    child: activeChats.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: activeChats.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final chat = activeChats[index];
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
      },
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
