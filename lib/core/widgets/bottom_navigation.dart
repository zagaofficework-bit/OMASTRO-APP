import 'dart:ui'; // Provides the ImageFilter for Gaussian blur
import 'package:flutter/material.dart';
import 'package:omastro/app/navigation/navigation_items.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
    final barHeight = responsive.bottomNavHeight;
    final horizontalMargin = responsive.isDesktop
        ? 40.0
        : responsive.isTablet
        ? 28.0
        : 16.0;

    // Helper to apply an opacity to a Gradient by adjusting its colors.
    Gradient gradientWithOpacity(Gradient gradient, double opacity) {
      if (gradient is LinearGradient) {
        return LinearGradient(
          colors: gradient.colors
              .map((c) => c.withValues(alpha: opacity))
              .toList(),
          stops: gradient.stops,
          begin: gradient.begin,
          end: gradient.end,
          tileMode: gradient.tileMode,
          transform: gradient.transform,
        );
      }
      // Fallback: return original gradient if it's not a LinearGradient
      return gradient;
    }

    return Container(
      margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 0),
      height: barHeight,
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusRound,
        border: Border.all(
          color: const Color.fromARGB(
            255,
            235,
            226,
            226,
          ).withValues(alpha: 0.40),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x00000000).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusRound,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
          child: Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.70),
              borderRadius: AppRadius.radiusRound,
            ),
            child: Material(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: navigationItems.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final item = entry.value;
                  final bool isSelected = currentIndex == index;

                  return Expanded(
                    child: Padding(
                      // Vertical padding ensures the golden active pill doesn't touch the outer capsule edges
                      padding: EdgeInsets.symmetric(
                        vertical: responsive.scale(6, min: 5, max: 8),
                        horizontal: responsive.scale(4, min: 2, max: 6),
                      ),
                      child: InkWell(
                        onTap: () => onTap(index),
                        borderRadius: AppRadius.radiusRound,
                        highlightColor: Colors.transparent,
                        splashColor: Colors
                            .transparent, // Removed to avoid clashing with the active pill look
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.radiusRound,
                            // Matches the warm golden/saffron background highlight pill in image_49a047.png
                            gradient: isSelected
                                ? gradientWithOpacity(
                                    AppColors.goldGradient,
                                    0.85,
                                  )
                                : gradientWithOpacity(
                                    AppColors.blackGradient,
                                    0.0,
                                  ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  // In image_49a047.png, the active icon becomes a dark charcoal color inside the pill
                                  color: isSelected
                                      ? const Color(0xff1C1B1F)
                                      : AppColors.textSecondary,
                                  size: responsive.scale(20, min: 18, max: 24),
                                ),
                                SizedBox(
                                  height: responsive.scale(3, min: 2, max: 5),
                                ),
                                Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: responsive.font(
                                      8,
                                      min: 7,
                                      max: 10,
                                    ),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? const Color(0xff1C1B1F)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
