import 'package:flutter/material.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import 'package:omastro/features/live/widget/live_astrologer_card.dart';
import 'package:omastro/features/live/widget/live_onboarding_banner.dart';
import '../../../core/theme/app_colors.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
    // Mock dataset representing the active streams visible in Live astrologers page.jpg
    final List<Map<String, String>> liveStreams = [
      {
        'category': 'Vedic',
        'title': 'Saturn Transit 2026 — what it means for you',
        'hostName': 'Acharya Ramesh',
        'viewers': '1,284',
        'imageUrl':
            'https://images.unsplash.com/photo-1532968961962-8a0cb3a2d4f5?q=80&w=600&auto=format&fit=crop', // Starry cosmos placeholder
      },
      {
        'category': 'Tarot',
        'title': 'Live Tarot — pick a card',
        'hostName': 'Pandit Suresh',
        'viewers': '942',
        'imageUrl':
            'https://images.unsplash.com/photo-1578632767115-351597cf2477?q=80&w=600&auto=format&fit=crop', // Mystic card setup placeholder
      },
      {
        'category': 'Career',
        'title': 'Career Q&A — open chat',
        'hostName': 'Maa Anjali',
        'viewers': '318',
        'imageUrl':
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600&auto=format&fit=crop', // Calm background placeholder
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: responsive.pageConstraints(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: responsive.heroTopGap),
                    // --- 1. Header & Live Indicator Badge Track ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Live now',
                                style: TextStyle(
                                  fontFamily: 'PlayfairDisplay',
                                  fontSize: responsive.font(
                                    26,
                                    min: 24,
                                    max: 32,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(
                                height: responsive.scale(4, min: 4, max: 6),
                              ),
                              Text(
                                'Join free streams from verified astrologers.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: responsive.font(
                                    12,
                                    min: 11,
                                    max: 14,
                                  ),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Small pulsing pink/red structural indicator pill from the image layout
                        // ✅ FIXED: Clean widget placement inside Row tracking
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          margin: const EdgeInsets.only(top: 6.0),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xffFEE2E2,
                            ), // Very soft pink backplate
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: const Row(
                            mainAxisSize:
                                MainAxisSize.min, // Keeps the pill compact
                            children: [
                              Icon(
                                Icons.circle,
                                color: Color(0xffEF4444),
                                size: 6,
                              ), // 👈 Just render the icon directly!
                              SizedBox(width: 4.0),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffEF4444),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.scale(24, min: 18, max: 30)),

                    // --- 2. Dynamic Live Stream Feed ---
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Flows seamlessly inside parent scroller
                      itemCount: liveStreams.length,
                      itemBuilder: (context, index) {
                        final stream = liveStreams[index];
                        return LiveAstrologerCard(
                          category: stream['category']!,
                          title: stream['title']!,
                          hostName: stream['hostName']!,
                          viewers: stream['viewers']!,
                          imageUrl: stream['imageUrl']!,
                          onTap: () {
                            debugPrint(
                              'Entering live stream hosted by: ${stream['hostName']}',
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: responsive.scale(12, min: 10, max: 16)),

                    // --- 3. Astrologer Stream Host Onboarding Banner ---
                    LiveOnboardingBanner(
                      onTap: () {
                        debugPrint(
                          'User clicked on live onboarding CTA button',
                        );
                      },
                    ),

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
