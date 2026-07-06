import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color(
              0x05000000,
            ), // Ultra-subtle 2% shadow to lift the card elegantly
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        style: AppTextStyles.bodyMedium,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: 'Search astrologers',
          hintStyle: AppTextStyles.bodySecondary.copyWith(
            color: AppColors.textLight,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
          // Clean capsule borders defined inside our centralized tokens
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusXl,
            borderSide: const BorderSide(color: AppColors.border, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusXl,
            borderSide: const BorderSide(color: AppColors.border, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusXl,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
          ),
        ),
      ),
    );
  }
}
