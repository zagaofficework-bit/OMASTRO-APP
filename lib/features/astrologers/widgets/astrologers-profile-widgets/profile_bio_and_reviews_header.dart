import 'package:flutter/material.dart';
import 'package:omastro/core/theme/app_colors.dart';

class ProfileBioAndReviewsHeader extends StatelessWidget {
  final String bioText;
  final VoidCallback onViewAllReviewsTap;

  const ProfileBioAndReviewsHeader({
    super.key,
    required this.bioText,
    required this.onViewAllReviewsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. BIOGRAPHY TEXT BLOCK ---
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              bioText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28.0),

        // --- 2. USER REVIEWS TRACK HEADER ROW ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'User Reviews',
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            // View All Interactive Link
            TextButton(
              onPressed: onViewAllReviewsTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xffD4931A), // Brand accent gold tone
                ),
              ),
            ),
          ],
        ),

        // Divider under the section
      ],
    );
  }
}
