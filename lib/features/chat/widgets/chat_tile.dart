import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/chat_conversation.dart';

class ChatTile extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  const ChatTile({super.key, required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Generates a two-letter avatar initials circle (e.g., "Astro Priya" -> "AP")
    final words = conversation.astrologerName.trim().split(' ');
    final initials = words
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();
    final displayInitials = initials.length > 2
        ? initials.substring(0, 2)
        : initials;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      // Anti-aliased clipping keeps the ripple inside your custom rounded borders
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors
            .transparent, // 👈 Allows the Container background to show through
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          onTap: onTap,

          // 1. Gold Monogram Initials Avatar
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.75,
              ), // Matches warm gold badge
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              displayInitials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),

          // 2. Astrologer Details & Text Columns
          title: Text(
            conversation.astrologerName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              conversation.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
            ),
          ),

          // 3. Right Aligned Timestamp Badge
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 4),
              Text(
                conversation.time,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
