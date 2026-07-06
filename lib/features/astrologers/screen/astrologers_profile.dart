import 'package:flutter/material.dart';
import 'package:omastro/core/theme/app_spacing.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/consultation_action_dock.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_avatar_frame.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_bio_and_reviews_header.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_meta_details.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_sub_header_bar.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_stats_card.dart'; // 👈 1. Added import statement
import '../../../core/theme/app_colors.dart';

class AstrologerProfilePage extends StatelessWidget {
  final Map<String, String> astrologerData;

  const AstrologerProfilePage({super.key, required this.astrologerData});

  @override
  Widget build(BuildContext context) {
    final String profileName = astrologerData['name'] ?? 'Astrologer';
    final String profileImageUrl = astrologerData['imageUrl'] ?? '';
    final String specialties = astrologerData['specialties'] ?? '';
    final String languages = astrologerData['languages'] ?? 'English';
    final String experienceYears = astrologerData['experience'] ?? '0 Years';
    final String hourlyRate = astrologerData['rate'] ?? '0';
    final String biography =
        astrologerData['bio'] ?? 'Verified Professional Astrologer.';

    // Optional: Extract values from map if you pass orders, followers, or mins dynamically later
    final String totalOrders = astrologerData['orders'] ?? '500';
    final String totalFollowers = astrologerData['followers'] ?? '2.5k+';
    final String totalMins = astrologerData['mins'] ?? '3k+';

    return Scaffold(
      backgroundColor: AppColors.background,

      body: Stack(
        children: [
          // --- Layer 1: Scrollable Core Information Viewport ---
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppSpacing.heightXl,
                AppSpacing.heightXs,
                AppSpacing.heightXs,

                ProfileSubHeaderBar(
                  title: 'Profile',
                  onBackTap: () => Navigator.of(context).pop(),
                  onShareTap: () {
                    debugPrint('Share profile clicked for: $profileName');
                  },
                ),

                const SizedBox(height: 24.0),

                // 📦 Component 2: Circular Profile Avatar with Active Online Dot
                ProfileAvatarFrame(imageUrl: profileImageUrl, isOnline: true),
                const SizedBox(height: 16.0),

                // 📦 Component 3: Core Identity Information & Rating Deck
                ProfileMetaDetails(
                  name: profileName,
                  specialties: specialties,
                  languages: languages,
                  experience: experienceYears,
                  ratePerMinute: hourlyRate,
                  onFollowTap: () {
                    debugPrint('Follow state updated for $profileName');
                  },
                ),
                const SizedBox(height: 16.0),

                // 📦 New Stats Component Section (Capsule layout from image_c0e5c7.png)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ProfileStatsCard(
                    ordersCount: totalOrders,
                    followersCount: totalFollowers,
                    minsCount: totalMins,
                  ),
                ),
                const SizedBox(height: 16.0),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: ConsultationActionDock(
                    onChatTap: () =>
                        debugPrint('Opening Chat interface with $profileName'),
                    onCallTap: () => debugPrint(
                      'Starting Direct Audio Bridge to $profileName',
                    ),
                    onVideoTap: () => debugPrint(
                      'Launching Video Consultation with $profileName',
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // 📦 Component 4: About Paragraph Biography & Reviews Track Header Row
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: ProfileBioAndReviewsHeader(
                    bioText: biography,
                    onViewAllReviewsTap: () {
                      debugPrint('Routing to complete user reviews deck...');
                    },
                  ),
                ),

                // Extra spacing buffer allows the view content to scroll cleanly
                const SizedBox(height: 180.0),
              ],
            ),
          ),

          // --- Layer 2: Fixed Bottom Action Dock for Consultation Options ---
        ],
      ),
    );
  }
}
