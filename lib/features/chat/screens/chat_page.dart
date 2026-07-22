import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/chat_tile.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';
import '../models/chat_conversation.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        List<ChatConversation> activeChats = [];
        if (state is ChatUpdatedState) {
          activeChats = state.activeConversations;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFDFBF7),
          body: Stack(
            children: [
              // Main Content
              Positioned.fill(
                child: activeChats.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: EdgeInsets.only(
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          top:
                              MediaQuery.of(context).padding.top +
                              80 +
                              AppSpacing.md, // offset for header
                          bottom: AppSpacing.md,
                        ),
                        itemCount: activeChats.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final chat = activeChats[index];
                          return ChatTile(
                            conversation: chat,
                            onTap: () {
                              context.push(
                                '/chat-room',
                                extra: {
                                  'id': chat.id,
                                  'name': chat.astrologerName,
                                  'otherUid': chat.otherUid,
                                  'avatarUrl': chat
                                      .profileImageUrl, // Pass avatarUrl to ChatRoomPage
                                },
                              );
                            },
                          );
                        },
                      ),
              ),

              // Glassmorphism Premium Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.only(
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                        top: MediaQuery.of(context).padding.top + 16,
                        bottom: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.7,
                        ), // Transparent for blur
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black.withValues(alpha: 0.05),
                            width: 1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Messages',
                            style: AppTextStyles.displayMedium.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No active conversations',
            style: AppTextStyles.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chat with an astrologer to seek guidance.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Find Astrologer',
              style: AppTextStyles.buttonText.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
