import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LiveOnboardingBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const LiveOnboardingBanner({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0xffEFEAE2), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x02000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- 1. Circular Astrology/Spark Icon Backplate ---
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xffD4A437), // Signature deep gold tone
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_outlined, // Minimal clean sparkles glyph
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 16.0),

          // --- 2. Descriptive Typographic Deck ---
          const Text(
            'Are you an astrologer?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6.0),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Go live, build your audience, and earn from gifts and consultations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 18.0),

          // --- 3. "Coming Soon" Pill Action Button ---
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: const Color(0xffF2E6CD), // Soft muted golden fill matching the image layout
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.group_add_outlined, // Clean host onboarding representation icon
                    size: 15,
                    color: Color(0xffB38219), // Deep golden accent tint
                  ),
                  SizedBox(width: 6.0),
                  Text(
                    'Go live (coming soon)',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xffB38219),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}