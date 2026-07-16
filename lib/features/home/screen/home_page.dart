import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:omastro/features/home/widgets/profile_completion_banner.dart';
import '../../astrologers/bloc/astrologers_bloc.dart';
import '../../astrologers/bloc/astrologers_event.dart';
import '../../wallet/bloc/wallet_bloc.dart';
import '../../wallet/bloc/wallet_event.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<AstrologersBloc>().add(LoadAstrologers());
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            context.read<AstrologersBloc>().add(LoadAstrologers());
            context.read<WalletBloc>().add(LoadWallet());
            context.read<ProfileBloc>().add(LoadProfileEvent());
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: responsive.pageConstraints(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 66),
                  
                  // --- Profile Completion Banner ---
                  _FadeInSlide(
                    delay: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.horizontalPadding,
                      ),
                      child: const ProfileCompletionBanner(),
                    ),
                  ),

                  // --- 1. Hero Text Layout Block ---
                  _FadeInSlide(
                    delay: 1,
                    child: Padding(
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
                  ),
                  SizedBox(height: responsive.scale(4, min: 4, max: 8)),
                  _FadeInSlide(
                    delay: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.horizontalPadding,
                      ),
                      child: const Text(
                        'Verified astrologers, on call or chat.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ),
                  AppSpacing.heightMd,
                  _FadeInSlide(
                    delay: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.horizontalPadding,
                      ),
                      child: const AppSearchBar(),
                    ),
                  ),
                  AppSpacing.heightMd,
                  _FadeInSlide(
                    delay: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.horizontalPadding,
                      ),
                      child: const HomeActionButtons(),
                    ),
                  ),
                  AppSpacing.heightMd,
                  _FadeInSlide(
                    delay: 3,
                    child: const HomeBannerSlider(),
                  ),
                  AppSpacing.heightMd,
                  _FadeInSlide(
                    delay: 3,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.horizontalPadding,
                      ),
                      child: const HomeCategoryGrid(),
                    ),
                  ),
                  AppSpacing.heightMd,
                  _FadeInSlide(
                    delay: 4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.horizontalPadding,
                      ),
                      child: const OnlineAstrologersSection(),
                    ),
                  ),
                  AppSpacing.heightMd,
                  _FadeInSlide(
                    delay: 4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.horizontalPadding,
                      ),
                      child: const TopAstrologersSection(),
                    ),
                  ),
                  AppSpacing.heightXl,
                  SizedBox(height: responsive.bottomInset),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}

class _FadeInSlide extends StatelessWidget {
  final Widget child;
  final int delay;

  const _FadeInSlide({
    required this.child,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (delay * 100)),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
