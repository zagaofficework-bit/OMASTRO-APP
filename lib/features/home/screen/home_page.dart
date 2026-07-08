import 'package:flutter/material.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import 'package:omastro/core/theme/app_colors.dart';
import 'package:omastro/core/theme/app_spacing.dart';
import 'package:omastro/core/theme/app_text_styles.dart';
import 'package:omastro/core/widgets/search_bar.dart';
import 'package:omastro/features/home/widgets/categories_grid.dart';
import 'package:omastro/features/home/widgets/home_banner.dart';
import 'package:omastro/features/home/widgets/home_page_buttons.dart';
import 'package:omastro/features/home/widgets/online_astrologer_card.dart';
import 'package:omastro/features/home/widgets/top_astrologer_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: responsive.pageConstraints(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 66),
                  // --- 1. Hero Text Layout Block ---
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.horizontalPadding,
                    ),
                    child: Text(
                      'Find your guide',
                      style: AppTextStyles.displayLarge02.copyWith(
                        fontSize: responsive.font(30, min: 26, max: 36),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: responsive.scale(4, min: 4, max: 8)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.horizontalPadding,
                    ),
                    child: Text(
                      'Verified astrologers, on call or chat.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  AppSpacing.heightMd,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.horizontalPadding,
                    ),
                    child: const AppSearchBar(),
                  ),
                  AppSpacing.heightMd,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.horizontalPadding,
                    ),
                    child: const HomeActionButtons(),
                  ),
                  AppSpacing.heightMd,
                  const HomeBannerSlider(),
                  AppSpacing.heightMd,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.horizontalPadding,
                    ),
                    child: const HomeCategoryGrid(),
                  ),
                  AppSpacing.heightMd,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.horizontalPadding,
                    ),
                    child: const OnlineAstrologersSection(),
                  ),
                  AppSpacing.heightMd,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.horizontalPadding,
                    ),
                    child: const TopAstrologersSection(),
                  ),
                  AppSpacing.heightXl,
                  SizedBox(height: responsive.bottomInset),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
