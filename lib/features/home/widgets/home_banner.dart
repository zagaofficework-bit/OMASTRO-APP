import 'package:flutter/material.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  final PageController _pageController = PageController();
  final ValueNotifier<double> _scrollNotifier = ValueNotifier<double>(0.0);

  final List<String> _bannerImages = [
    'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1506318137071-a8e063b4bec0?q=80&w=600&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        _scrollNotifier.value = _pageController.page ?? 0.0;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    return Column(
      children: [
        // --- 1. Horizontal PageView Slider ---
        SizedBox(
          height: responsive.bannerHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _bannerImages.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding,
                ),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: AppColors.border, width: 1.0),
                  image: DecorationImage(
                    image: NetworkImage(_bannerImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.radiusMd,
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  padding: EdgeInsets.all(
                    responsive.scale(20, min: 16, max: 28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        index == 0
                            ? 'Discover your stars'
                            : index == 1
                            ? 'Daily Horoscopes'
                            : 'Connect with Guides',
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: responsive.font(18, min: 16, max: 24),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: responsive.scale(4, min: 4, max: 8)),
                      Text(
                        index == 0
                            ? 'First chat free'
                            : index == 1
                            ? 'Honest & accurate insights'
                            : 'Available 24/7 on call',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: responsive.font(11, min: 10, max: 14),
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // --- 2. Custom Progress Tracker Line (Fixed Layout Hierarchy) ---
        ValueListenableBuilder<double>(
          valueListenable: _scrollNotifier,
          builder: (context, pagePosition, _) {
            return Container(
              height: 3.0,
              width: 80.0,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
              // LayoutBuilder goes OUTSIDE the Stack so Positioned works correctly
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double maxExtent = constraints.maxWidth;
                  final double indicatorWidth =
                      maxExtent / _bannerImages.length;
                  final double leftOffset = (pagePosition * indicatorWidth)
                      .clamp(0.0, maxExtent - indicatorWidth);

                  return Stack(
                    children: [
                      Positioned(
                        left: leftOffset,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: indicatorWidth,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
