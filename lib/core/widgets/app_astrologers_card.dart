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
    final responsive = context.responsive;

    return SizedBox(
      width: responsive.featuredCardWidth,
      height: responsive.featuredCardHeight,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusMd,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.radiusMd,
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;

              final avatarRadius = (h * 0.18).clamp(24.0, 36.0);

              return Padding(
                padding: EdgeInsets.all(responsive.scale(10, min: 8, max: 14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: AppColors.background,
                          backgroundImage: imageUrl.startsWith('assets/')
                              ? AssetImage(imageUrl)
                              : NetworkImage(imageUrl) as ImageProvider,
                        ),

                        if (isOnline)
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              width: responsive.scale(12),
                              height: responsive.scale(12),
                              decoration: BoxDecoration(
                                color: const Color(0xff4CAF50),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: responsive.scale(8)),

                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: responsive.font(13, min: 12, max: 15),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: responsive.scale(3)),

                    Text(
                      specialty,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: responsive.font(10, min: 9, max: 12),
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.primary,
                          size: responsive.scale(14, min: 12, max: 16),
                        ),

                        SizedBox(width: responsive.scale(2)),

                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: responsive.font(11, min: 10, max: 13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: responsive.scale(5)),

                    Text(
                      "₹$pricePerMin/min",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: responsive.font(12, min: 11, max: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
