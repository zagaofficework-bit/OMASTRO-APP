import 'package:flutter/material.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import '../../../core/theme/app_colors.dart';

class StoreHeader extends StatelessWidget {
  const StoreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        responsive.scale(16, min: 12, max: 22),
        responsive.horizontalPadding,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Left Section: Brand & Product Typography Copy ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small uppercase sub-banner note text
                Text(
                  'POWERED BY OM RUDRAKSHA JEWELS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: responsive.font(10, min: 9, max: 12),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: responsive.scale(6, min: 5, max: 8)),

                // Main Header Title Line: Elegant serif display block
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily:
                          'PlayfairDisplay', // Matching the elegant look from E-store page.jpg
                      fontSize: responsive.font(28, min: 24, max: 34),
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Sacred ',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      // Golden/Saffron style match for highlight accent word
                      const TextSpan(
                        text: 'jewellery ',
                        style: TextStyle(color: Color(0xffD4A437)),
                      ),
                      const TextSpan(
                        text: '& idols',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: responsive.scale(8, min: 6, max: 10)),

                // Descriptive subtext line copy block
                Text(
                  'Energized Rudraksha, crystal bracelets, Makrana marble idols and more.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: responsive.font(13, min: 12, max: 15),
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.scale(16, min: 12, max: 20)),

          // --- Right Section: Float Action Shopping Bag Pill Button ---
          Container(
            width: responsive.scale(42, min: 38, max: 48),
            height: responsive.scale(42, min: 38, max: 48),
            decoration: BoxDecoration(
              color: const Color(
                0xffF8F2E8,
              ), // Light warm amber background accent ring
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xffE4A834).withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Optional: Can tie into shopping bag state interactions later
                },
                customBorder: const CircleBorder(),
                child: Icon(
                  Icons
                      .local_mall_outlined, // Elegant minimalistic bag icon representation
                  color: Color(0xffAD7A18),
                  size: responsive.scale(20, min: 18, max: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
