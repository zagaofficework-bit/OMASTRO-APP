import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class FeaturedAstrologerCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String specialty;
  final double rating;
  final int pricePerMin;
  final bool isOnline;
  final VoidCallback onTap;

  const FeaturedAstrologerCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.specialty,
    required this.rating,
    required this.pricePerMin,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMd,
      child: Container(
        width: 150, // Fixed horizontal track column block width
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(color: AppColors.border, width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Portrait Frame + Presence Indicator Dot ---
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.background,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50), // Emerald presence green color
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 2.0),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // --- Astrologer Identity Name ---
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              
              // --- Specialty Subtitle Label ---
              Text(
                specialty,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),

              // --- Ratings / Star Layout Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.primary, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // --- Fee Pricing Tag Block ---
              Text(
                '₹$pricePerMin/min',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}