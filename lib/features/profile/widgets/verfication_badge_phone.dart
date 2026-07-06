import 'package:flutter/material.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class VerificationBadge extends StatelessWidget {
  final bool isVerified;
  final VoidCallback? onTap;

  const VerificationBadge({super.key, required this.isVerified, this.onTap});

  @override
  Widget build(BuildContext context) {
    // 1. Render green success state if account tracking parameter is verified
    if (isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9), // Clean light green background
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 12, color: Color(0xFF2E7D32)),
            SizedBox(width: 4),
            Text(
              'Verified',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // 2. Render an interactive amber badge if parameter is unverified
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0), // Soft warning amber backdrop
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: const Color(0xFFFFE0B2), width: 0.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 12,
              color: Color(0xFFE65100),
            ),
            SizedBox(width: 4),
            Text(
              'Verify Now',
              style: TextStyle(
                color: Color(0xFFE65100),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
