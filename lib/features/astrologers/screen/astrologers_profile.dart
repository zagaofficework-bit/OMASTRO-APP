import 'package:flutter/material.dart';
import 'package:omastro/core/theme/app_spacing.dart';
import 'package:omastro/core/theme/app_text_styles.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/consultation_action_dock.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_avatar_frame.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_bio_and_reviews_header.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_meta_details.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_sub_header_bar.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_stats_card.dart'; // 👈 1. Added import statement
import '../../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../following_provider.dart';

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
      appBar: AppBar(
        backgroundColor: const Color(0xffFAF6F0),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: Text(
          'Profile Details',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              debugPrint('Share profile clicked for: $profileName');
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Top Golden banner decoration layer
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xffE4A834), Color(0xffD4931A)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                ),
                // Floating Details Card
                Padding(
                  padding: const EdgeInsets.only(
                    top: 40.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        ProfileAvatarFrame(
                          imageUrl: profileImageUrl,
                          isOnline: true,
                        ),
                        const SizedBox(height: 16),
                        // Meta Details (Name, Rating, Specialties, rate, Follow button)
                        ListenableBuilder(
                          listenable: globalFollowingProvider,
                          builder: (context, _) {
                            final bool isFollowing = globalFollowingProvider
                                .isFollowing(profileName);
                            return ProfileMetaDetails(
                              name: profileName,
                              specialties: specialties,
                              languages: languages,
                              experience: experienceYears,
                              ratePerMinute: hourlyRate,
                              isFollowing: isFollowing,
                              onFollowTap: () {
                                globalFollowingProvider.toggleFollow(
                                  profileName,
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xffFAF6F0), thickness: 1.5),
                        const SizedBox(height: 16),
                        // Stats Card
                        ProfileStatsCard(
                          ordersCount: totalOrders,
                          followersCount: totalFollowers,
                          minsCount: totalMins,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Consultation Options Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.flash_on_rounded,
                          color: Color(0xffE4A834),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Consultation Options',
                          style: AppTextStyles.headingMedium.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ConsultationActionDock(
                      onChatTap: () {
                        context.push(
                          '/chat-room',
                          extra: {
                            'id':
                                'chat_${profileName.toLowerCase().replaceAll(' ', '_')}',
                            'name': profileName,
                          },
                        );
                      },
                      onCallTap: () {
                        context.push(
                          '/live-call',
                          extra: {
                            'name': profileName,
                            'image': profileImageUrl,
                          },
                        );
                      },
                      onVideoTap: () {
                        context.push(
                          '/video-call',
                          extra: {
                            'name': profileName,
                            'image': profileImageUrl,
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // About Card & Reviews
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xffE4A834),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About Astrologer',
                          style: AppTextStyles.headingMedium.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      biography,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.rate_review_outlined,
                              color: Color(0xffE4A834),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'User Reviews',
                              style: AppTextStyles.headingMedium.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Color(0xffE4A834),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildReviewItem(
                      'Rohan K.',
                      5.0,
                      'Very accurate prediction! Highly recommended.',
                      '2 hours ago',
                    ),
                    const Divider(height: 24),
                    _buildReviewItem(
                      'Neha S.',
                      5.0,
                      'Felt so peaceful talking to her. Clean explanations and remediation guides.',
                      '1 day ago',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(
    String name,
    double rating,
    String comment,
    String time,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            rating.toInt(),
            (index) => const Icon(
              Icons.star_rounded,
              color: Color(0xffE4A834),
              size: 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          comment,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
