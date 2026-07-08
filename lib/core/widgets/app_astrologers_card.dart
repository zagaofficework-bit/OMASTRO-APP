import 'package:flutter/material.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
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
    final responsive = ResponsiveProvider.of(context);
    final avatarRadius = responsive.scale(30, min: 26, max: 38);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMd,
      child: Container(
        width: responsive.featuredCardWidth,
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
          padding: EdgeInsets.all(responsive.scale(12, min: 10, max: 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Portrait Frame + Presence Indicator Dot ---
              Stack(
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: AppColors.background,
                    backgroundImage: imageUrl.startsWith('assets/')
                        ? AssetImage(imageUrl) as ImageProvider
                        : NetworkImage(imageUrl),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: responsive.scale(12, min: 10, max: 14),
                        height: responsive.scale(12, min: 10, max: 14),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF4CAF50,
                          ), // Emerald presence green color
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: responsive.scale(8, min: 6, max: 10)),

              // --- Astrologer Identity Name ---
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: responsive.font(13, min: 12, max: 15),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              // --- Specialty Subtitle Label ---
              Text(
                specialty,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: responsive.font(10, min: 9, max: 12),
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: responsive.scale(6, min: 4, max: 8)),

              // --- Ratings / Star Layout Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: AppColors.primary,
                    size: responsive.scale(14, min: 12, max: 16),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: responsive.font(11, min: 10, max: 13),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.scale(8, min: 6, max: 10)),

              // --- Fee Pricing Tag Block ---
              Text(
                '₹$pricePerMin/min',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: responsive.font(12, min: 11, max: 14),
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
