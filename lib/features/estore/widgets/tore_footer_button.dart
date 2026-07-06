import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

class StoreFooterButton extends StatelessWidget {
  final VoidCallback onTap;

  const StoreFooterButton({super.key, required this.onTap});

  // url louncher function to open the store website in an external browser

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- 1. Main Wide Golden Action Button ---
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xffD4A437,
                ), // Signature golden tone matching E-store page.jpg
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius
                      .radiusRound, // Standardized rounded capsule theme shape
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Browse the full store ',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons
                        .open_in_new_rounded, // Clear external redirection arrow glyph representation
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12.0),

          // --- 2. Information/Notice Subtext ---
          Center(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "You'll be taken to omrudrakshajewels.com to complete checkout.",
                // Ensures balance layout over multi-lines
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
