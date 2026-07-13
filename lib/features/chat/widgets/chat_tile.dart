import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/chat_conversation.dart';
import '../../astrologers/bloc/astrologers_bloc.dart';
import '../../astrologers/bloc/astrologers_state.dart';

class ChatTile extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  const ChatTile({super.key, required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final words = conversation.astrologerName.trim().split(' ');
    final initials = words.map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
    final displayInitials = initials.length > 2 ? initials.substring(0, 2) : initials;

    return BlocBuilder<AstrologersBloc, AstrologersState>(
      builder: (context, astroState) {
        String? avatarUrl;
        if (astroState is AstrologersFollowingState) {
          try {
            final astro = astroState.astrologers.firstWhere((a) => a['id'] == conversation.id);
            avatarUrl = astro['avatar_url'];
          } catch (_) {}
        }

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    // Avatar with online indicator
                    Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                          ),
                          child: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: avatarUrl != null
                                ? NetworkImage(avatarUrl!)
                                : (conversation.profileImageUrl != null
                                    ? (conversation.profileImageUrl!.startsWith('http')
                                        ? NetworkImage(conversation.profileImageUrl!)
                                        : AssetImage(conversation.profileImageUrl!) as ImageProvider)
                                    : null),
                            child: (avatarUrl == null && conversation.profileImageUrl == null)
                                ? Text(displayInitials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18))
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 4,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Name and Message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                conversation.astrologerName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                conversation.time,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  conversation.lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
                                ),
                              ),
                              // Optional unread badge or icon could go here
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey[300],
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
