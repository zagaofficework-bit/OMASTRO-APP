import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.heightXl,
              AppSpacing.heightXl,
              // --- 1. Hero Text Layout Block ---
              Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  left: 10.0,
                  right: 8.0,
                ),
                child: Text(
                  'Find your guide',
                  style: AppTextStyles.displayLarge02.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 8.0),
                child: Text(
                  'Verified astrologers, on call or chat.',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              AppSpacing.heightMd,
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: AppSearchBar(),
              ),
              AppSpacing.heightMd,
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: HomeActionButtons(),
              ),
              AppSpacing.heightMd,
              HomeBannerSlider(),
              AppSpacing.heightMd,
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: const HomeCategoryGrid(),
              ),
              AppSpacing.heightMd,
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: const OnlineAstrologersSection(),
              ),
              AppSpacing.heightMd,
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: const TopAstrologersSection(),
              ),
              AppSpacing.heightXl,
              AppSpacing.heightXl,
              AppSpacing.heightXl,
            ],
          ),
        ),
      ),
    );
  }
}
