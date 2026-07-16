import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DynamicGreetingHeader extends StatelessWidget {
  final String email;
  final String? explicitName;
  final String? avatarUrl;

  const DynamicGreetingHeader({
    super.key,
    required this.email,
    this.explicitName,
    this.avatarUrl,
  });

  /// Extracts a clean, capitalized name from the email handle for smooth UX
  String _extractNameFromEmail(String rawEmail) {
    if (rawEmail.isEmpty || !rawEmail.contains('@')) return 'User';

    // 1. Isolate the local handle part before the domain
    String localPart = rawEmail.split('@').first;

    // 2. Replace common dividers (dots, dashes, underscores) with spaces
    String cleanedName = localPart.replaceAll(RegExp(r'[._-]'), ' ');

    // 3. Strip trailing numerical characters
    cleanedName = cleanedName.replaceAll(RegExp(r'\d'), '');

    // 4. Split and transform each word into Capital Case
    return cleanedName
        .trim()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // Determine target name display mapping prioritize explicit overrides
    final String displayName =
        (explicitName != null && explicitName!.isNotEmpty)
        ? explicitName!
        : 'User';

    // Dynamic initial letter extractor
    final String initialLetter = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : 'U';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Premium Profile Picture Display Frame
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? CircleAvatar(
                    radius: 44,
                    backgroundImage: NetworkImage(avatarUrl!),
                    backgroundColor: Colors.transparent,
                  )
                : Text(
                    initialLetter,
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
          ),
          const SizedBox(height: 12),

          // Context Welcome Greeting Lines
          Text(
            'Welcome back,',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 2),
          Text(
            displayName,
            style: AppTextStyles.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
