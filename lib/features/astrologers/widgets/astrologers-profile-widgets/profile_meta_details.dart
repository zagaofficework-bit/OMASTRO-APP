import 'package:flutter/material.dart';
import 'package:omastro/core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileMetaDetails extends StatelessWidget {
  final String name;
  final String specialties;
  final String languages;
  final String experience;
  final String ratePerMinute;
  final VoidCallback onFollowTap;

  const ProfileMetaDetails({
    super.key,
    required this.name,
    required this.specialties,
    required this.languages,
    required this.experience,
    required this.ratePerMinute,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- 1. NAME & + FOLLOW ROW ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8.0),

            // Capsule Follow Button
            InkWell(
              onTap: onFollowTap,
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffE4A834), // Golden brand primary color
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 12),
                    SizedBox(width: 2.0),
                    Text(
                      'Follow',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
            color: Color(0xffD4931A), // Prominent Ochre/Gold for pricing
          ),
        ),
        AppSpacing.heightMd, // Vertical spacing after the rate
      ],
    );
  }
}
