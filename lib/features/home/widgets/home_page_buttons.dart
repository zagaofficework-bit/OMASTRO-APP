import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeActionButtons extends StatelessWidget {
  const HomeActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
    final buttonGap = responsive.scale(12, min: 8, max: 14);

    final buttons = [
      _ActionButton(
        icon: Icons.chat_bubble_outline,
        label: 'Chat with Astrologer',
        onTap: () => context.go('/hub-list/:category'),
      ),
      _ActionButton(
        icon: Icons.call_outlined,
        label: 'Call with Astrologer',
        onTap: () => context.go('/hub-list/:category'),
      ),
    ];

    if (responsive.width < 340) {
      return Column(
        children: [
          buttons[0],
          SizedBox(height: buttonGap),
          buttons[1],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: buttons[0]),
        SizedBox(width: buttonGap),
        Expanded(child: buttons[1]),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusRound,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.scale(10, min: 8, max: 14),
          vertical: responsive.scale(14, min: 12, max: 16),
        ),
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: AppRadius.radiusRound,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.darkSurface,
              size: responsive.scale(18, min: 16, max: 20),
            ),
            SizedBox(width: responsive.scale(8, min: 6, max: 10)),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: responsive.font(12, min: 11, max: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
