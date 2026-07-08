import 'package:flutter/material.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import '../../../core/theme/app_colors.dart';

class LiveAstrologerCard extends StatelessWidget {
  final String category;
  final String title;
  final String hostName;
  final String viewers;
  final String imageUrl;
  final VoidCallback onTap;

  const LiveAstrologerCard({
    super.key,
    required this.category,
    required this.title,
    required this.hostName,
    required this.viewers,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: responsive.scale(16, min: 12, max: 20)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xffEFEAE2), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Thumbnail Viewport with Floating Overlays ---
              AspectRatio(
                aspectRatio:
                    16 /
                    9, // Standard widescreen layout matching Live astrologers page.jpg
                child: Stack(
                  children: [
                    // Base Placeholder / Image stream track
                    Container(
                      width: double.infinity,
                      color: const Color(0xff121212),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.live_tv_rounded,
                                color: Colors.white24,
                                size: 40,
                              ),
                            ),
                      ),
                    ),

                    // Bottom Linear Shadow Mask Overlay for scannability
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Floating Status Metrics (Live Badge & Viewer Count)
                    Positioned(
                      left: 12,
                      bottom: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Live Indicator Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xffEF4444,
                              ), // Vibrant live red
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.sensors_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Active Viewer Count Tag
                          Row(
                            children: [
                              const Icon(
                                Icons.visibility_outlined,
                                color: Colors.white,
                                size: 13,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                viewers,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- 2. Information Deck Meta Labels ---
              Padding(
                padding: EdgeInsets.all(responsive.scale(14, min: 12, max: 18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: responsive.font(10, min: 9, max: 12),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: responsive.scale(4, min: 4, max: 6)),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: responsive.font(16.5, min: 15, max: 20),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: responsive.scale(2, min: 2, max: 4)),
                    Text(
                      hostName,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: responsive.font(12, min: 11, max: 14),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
