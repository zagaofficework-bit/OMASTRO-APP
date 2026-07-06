import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeActionButtons extends StatelessWidget {
  const HomeActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // --- Chat Button ---
        Expanded(
          child: InkWell(
            onTap: () {
              context.go('/hub-list/:category'); // Navigate to the chat page
            }, // Interactive routing will be added in Phase 2
            borderRadius: AppRadius.radiusRound,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius:
                    AppRadius.radiusRound, // Uses our 99.0 capsule token
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.darkSurface,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Chat with Astrologer',
                    style: AppTextStyles.buttonText.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12), // Horizontal gap between the two buttons
        // --- Call Button ---
        Expanded(
          child: InkWell(
            onTap: () {
              context.go('/hub-list/:category');
            }, // Interactive routing will be added in Phase 2
            borderRadius: AppRadius.radiusRound,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: AppRadius.radiusRound,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.call_outlined,
                    color: AppColors.darkSurface,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Call with Astrologer',
                    style: AppTextStyles.buttonText.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
