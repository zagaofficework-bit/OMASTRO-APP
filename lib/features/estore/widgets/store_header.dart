import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StoreHeader extends StatelessWidget {

  const StoreHeader({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Left Section: Brand & Product Typography Copy ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small uppercase sub-banner note text
                const Text(
                  'POWERED BY OM RUDRAKSHA JEWELS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6.0),

                // Main Header Title Line: Elegant serif display block
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily:
                          'PlayfairDisplay', // Matching the elegant look from E-store page.jpg
                      fontSize: 28.0,
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
                const SizedBox(height: 8.0),

                // Descriptive subtext line copy block
                const Text(
                  'Energized Rudraksha, crystal bracelets, Makrana marble idols and more.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.0,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),

          // --- Right Section: Float Action Shopping Bag Pill Button ---
          Container(
            width: 42,
            height: 42,
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
                child: const Icon(
                  Icons
                      .local_mall_outlined, // Elegant minimalistic bag icon representation
                  color: Color(0xffAD7A18),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
