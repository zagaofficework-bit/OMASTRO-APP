import 'package:flutter/material.dart';
import 'package:omastro/core/theme/app_text_styles.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/consultation_action_dock.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_avatar_frame.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_meta_details.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_stats_card.dart'; // 👈 1. Added import statement
import '../../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/astrologers_bloc.dart';
import '../bloc/astrologers_event.dart';
import '../bloc/astrologers_state.dart';
import '../../reviews/bloc/reviews_bloc.dart';
import '../../reviews/bloc/reviews_state.dart';
import '../../reviews/widgets/write_review_bottom_sheet.dart';

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
                        BlocBuilder<AstrologersBloc, AstrologersState>(
                          builder: (context, state) {
                            bool isFollowing = false;
                            if (state is AstrologersFollowingState) {
                              isFollowing = state.followedAstrologers.contains(profileName);
                            }
                            return ProfileMetaDetails(
                              name: profileName,
                              specialties: specialties,
                              languages: languages,
                              experience: experienceYears,
                              ratePerMinute: hourlyRate,
                              isFollowing: isFollowing,
                              onFollowTap: () {
                                context.read<AstrologersBloc>().add(
                                  ToggleFollowAstrologer(profileName),
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
                            'id': astrologerData['id'] ?? 'chat_${profileName.toLowerCase().replaceAll(' ', '_')}',
                            'name': profileName,
                            'otherUid': astrologerData['firebase_uid'],
                          },
                        );
                      },
                      onCallTap: () {
                        context.push(
                          '/live-call',
                          extra: {
                            ...astrologerData,
                            'name': profileName,
                            'image': profileImageUrl,
                          },
                        );
                      },
                      onVideoTap: () {
                        context.push(
                          '/video-call',
                          extra: {
                            ...astrologerData,
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
                        TextButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (context) => WriteReviewBottomSheet(astrologerName: profileName),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xffE4A834)),
                          label: const Text(
                            'Write Review',
                            style: TextStyle(
                              color: Color(0xffE4A834),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<ReviewsBloc, ReviewsState>(
                      builder: (context, state) {
                        if (state is ReviewsUpdatedState) {
                          // Try getting specific reviews, fallback to generic DEFAULT reviews
                          final reviews = state.reviews[profileName] ?? state.reviews['DEFAULT'] ?? [];
                          
                          if (reviews.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text('No reviews yet. Be the first to review!', style: TextStyle(color: Colors.grey[600])),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            separatorBuilder: (context, index) => const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final review = reviews[index];
                              
                              String formattedTime;
                              final difference = DateTime.now().difference(review.timestamp);
                              if (difference.inMinutes < 60) {
                                formattedTime = '${difference.inMinutes} mins ago';
                              } else if (difference.inHours < 24) {
                                formattedTime = '${difference.inHours} hours ago';
                              } else {
                                formattedTime = '${difference.inDays} days ago';
                              }

                              return _buildReviewItem(
                                review.userName,
                                review.rating,
                                review.comment,
                                formattedTime,
                              );
                            },
                          );
                        }
                        return const CircularProgressIndicator();
                      },
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
