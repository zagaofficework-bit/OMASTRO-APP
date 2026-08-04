import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  static const List<String> _cosmicQuotes = [
    "The stars align to illuminate your path. Seek clarity in career & relationships today.",
    "Trust the timing of your life. The cosmos is organizing a beautiful breakthrough for you.",
    "Your energy is your power. Protect your peace and focus on self-transformation today.",
    "The universe doesn't speak English; it speaks frequency. Align your thoughts with your desires.",
    "A phase of confusion is ending. Clearer answers and divine guidance are heading your way.",
    "Your chart shows strength in adversity. Keep moving forward, protection is around you.",
    "Mercury’s currents encourage deep reflection. Speak with wisdom and listen to your heart.",
    "A new moon brings fresh starts. Write down your intentions and watch them manifest.",
    "Your career house is illuminated. A positive shift or new opportunity is manifesting soon.",
    "Venus shines brightly in your relationship sphere. Love and harmony are flowing to you.",
    "Jupiter’s expansion is guiding your learning. Trust the lessons you are receiving today.",
    "Listen to your intuition today. The quiet voice inside you knows the cosmic truth.",
    "Release what no longer serves your growth. Make space for divine abundance.",
    "Your strength lies in your spiritual alignment. Ground yourself in peace today.",
    "Every planetary transition is an invitation to grow. Embrace the cosmic shifts.",
    "A financial breakthrough is aligning. Keep your focus on abundance and manifestation.",
    "The universe is testing your resolve. Stay strong, the rewards will be magnificent.",
    "Your solar house brings vitality and health. Nourish your soul with positive thoughts.",
    "The cosmic winds are changing. Prepare to sail into a harbor of peace and prosperity.",
    "Opportunities are like stars—countless and waiting for you to notice them.",
    "Your birth chart is a blueprint of your soul. Remember who you are and stand tall.",
    "Saturn's discipline is molding you into a leader. Patience is your greatest tool.",
    "A divine message is seeking you. Quiet your mind and you will hear the answers.",
    "Your heart knows the path before your mind does. Let love guide your actions today.",
    "Mars brings courage and drive. Channel this energy to complete your vital tasks.",
    "The alignments favor reconciliation today. Forgive, heal, and let peace return.",
    "Every challenge is a stellar coordinate guiding you to your highest self.",
    "Your aura is bright and magnetic today. You will attract positive connections.",
    "Seek guidance when the path is foggy. Clear answers are waiting to be revealed.",
    "The moon shines reflection on your dreams. Pay attention to your nighttime insights.",
    "Abundance is your natural birthright. Shift your mindset from lack to fulfillment.",
    "The cosmos is whisper-guiding you. Take a deep breath and trust the journey.",
    "Your destiny is active. The choices you make today create ripples across time.",
    "Neptune’s dreams inspire your creativity today. Paint, write, and create without fear.",
    "A karmic cycle is successfully closing. Step into your power with a clean slate.",
    "The stars suggest a day of rest and recovery. Recharge your spiritual battery.",
    "Align with people who celebrate your light. Positive associations bring growth.",
    "A surprise conversation today may unlock a door you thought was closed forever.",
    "Your cosmic shield is strong today. Negativity cannot penetrate your peace.",
    "The planets favor bold decisions today. Trust your gut and make the leap.",
    "Your throat chakra is open. Speak your truth with kindness and clarity.",
    "A blessing in disguise is approaching. Keep an open heart and positive mind.",
    "Uranus brings unexpected breakthroughs. Embrace sudden changes as opportunities.",
    "The alignment is perfect for setting long-term goals. Plan your future with hope.",
    "You are co-creating your life with the cosmos. Be intentional about your thoughts.",
    "Your roots are deep, and your spirit is infinite. Stand firm in your truth.",
    "The divine light within you is brighter than any shadow. Shine without apology.",
    "A quiet moment of meditation today will reveal the cosmic answers you seek.",
    "The universe has your back. Let go of worry and trust the divine flow.",
    "Your future is written in the stars, but your actions hold the pen.",
  ];

  String _currentQuote = '';

  void _randomizeQuote() {
    final index = DateTime.now().microsecondsSinceEpoch % _cosmicQuotes.length;
    setState(() {
      _currentQuote = _cosmicQuotes[index];
    });
  }

  @override
  void initState() {
    super.initState();
    _randomizeQuote();
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
            _randomizeQuote();
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8EE),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: const Color(0xFFF1E6D2),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 10,
                                        color: Color(0xFFD97706),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'WELCOME TO OMASTRO',
                                        style: TextStyle(
                                          color: Color(0xFFB45309),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 9,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Discover Your Path',
                              style: AppTextStyles.displayLarge02.copyWith(
                                fontSize: responsive.font(32, min: 28, max: 38),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'serif',
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Connect with India\'s finest spiritual guides over secure call or chat.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: responsive.font(14, min: 12, max: 16),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ],
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
                        child: GestureDetector(
                          onTap: _randomizeQuote,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF8EE), Color(0xFFFDF0D5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFF5E3C3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFD97706,
                                  ).withValues(alpha: 0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.auto_awesome_rounded,
                                            color: Color(0xFFD97706),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'COSMIC GUIDANCE',
                                            style: TextStyle(
                                              color: const Color(0xFFB45309),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _currentQuote.isNotEmpty
                                            ? _currentQuote
                                            : 'The stars align to illuminate your path. Seek clarity in career & relationships today.',
                                        style: const TextStyle(
                                          color: Color(0xFF451A03),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFEF3C7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.dark_mode_rounded,
                                    color: Color(0xFFD97706),
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.heightMd,
                    // _FadeInSlide(
                    //   delay: 2,
                    //   child: Padding(
                    //     padding: EdgeInsets.symmetric(
                    //       horizontal: responsive.horizontalPadding,
                    //     ),
                    //     child: const HomeActionButtons(),
                    //   ),
                    // ),
                    AppSpacing.heightMd,
                    _FadeInSlide(delay: 3, child: const HomeBannerSlider()),
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

  Widget _buildCategoryChip(BuildContext context, String emoji, String name) {
    return GestureDetector(
      onTap: () => context.go('/astrologers?search=$name'),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFFF1E6D2), // Sleek warm gold border
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFD97706,
              ).withValues(alpha: 0.03), // Subtle warm amber shadow
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FadeInSlide extends StatelessWidget {
  final Widget child;
  final int delay;

  const _FadeInSlide({required this.child, this.delay = 0});

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
