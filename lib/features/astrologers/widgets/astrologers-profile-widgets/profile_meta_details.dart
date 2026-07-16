import 'package:flutter/material.dart';
import 'package:omastro/core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileMetaDetails extends StatelessWidget {
  final String name;
  final String specialties;
  final String languages;
  final String experience;
  final String ratePerMinute;

  const ProfileMetaDetails({
    super.key,
    required this.name,
    required this.specialties,
    required this.languages,
    required this.experience,
    required this.ratePerMinute,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- 1. NAME ---
        Text(
          name,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6.0),

        // --- 2. SPECIALTIES / SKILLS ---
        Text(
          specialties,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2.0),

        // --- 3. SPOKEN LANGUAGES ---
        Text(
          languages,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2.0),

        // --- 4. EXPERIENCE METRIC ---
        Text(
          'Exp $experience',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6.0),

        // --- 5. STAR RATING ROW ---
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_rounded, color: Color(0xffE4A834), size: 18),
            Icon(Icons.star_rounded, color: Color(0xffE4A834), size: 18),
            Icon(Icons.star_rounded, color: Color(0xffE4A834), size: 18),
            Icon(Icons.star_rounded, color: Color(0xffE4A834), size: 18),
            Icon(Icons.star_rounded, color: Color(0xffE4A834), size: 18),
          ],
        ),
        const SizedBox(height: 8.0),

        // --- 6. CONSULTATION RATE PER MINUTE ---
        Text(
          '₹$ratePerMinute/min',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xffD4931A),
          ),
        ),
        AppSpacing.heightMd,
      ],
    );
  }
}
