import 'package:flutter/material.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import '../../../core/theme/app_colors.dart';

class LiveOnboardingBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const LiveOnboardingBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsive.scale(20, min: 16, max: 28),
        vertical: responsive.scale(24, min: 20, max: 32),
      ),
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
            width: responsive.scale(48, min: 42, max: 56),
            height: responsive.scale(48, min: 42, max: 56),
            decoration: const BoxDecoration(
              color: Color(0xffD4A437), // Signature deep gold tone
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_outlined, // Minimal clean sparkles glyph
              color: Colors.white,
              size: responsive.scale(22, min: 20, max: 26),
            ),
          ),
          SizedBox(height: responsive.scale(16, min: 12, max: 20)),

          // --- 2. Descriptive Typographic Deck ---
          Text(
            'Are you an astrologer?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: responsive.font(20, min: 18, max: 24),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: responsive.scale(6, min: 5, max: 8)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.scale(16, min: 8, max: 24),
            ),
            child: Text(
              'Go live, build your audience, and earn from gifts and consultations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: responsive.font(12, min: 11, max: 14),
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: responsive.scale(18, min: 14, max: 22)),

          // --- 3. "Coming Soon" Pill Action Button ---
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.scale(18, min: 14, max: 22),
                vertical: responsive.scale(10, min: 8, max: 12),
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xffF2E6CD,
                ), // Soft muted golden fill matching the image layout
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .group_add_outlined, // Clean host onboarding representation icon
                    size: responsive.scale(15, min: 14, max: 17),
                    color: Color(0xffB38219), // Deep golden accent tint
                  ),
                  SizedBox(width: responsive.scale(6, min: 5, max: 8)),
                  Text(
                    'Go live (coming soon)',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: responsive.font(12, min: 11, max: 14),
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
