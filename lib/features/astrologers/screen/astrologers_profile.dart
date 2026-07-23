import 'package:flutter/material.dart';
import 'dart:async';
import 'package:omastro/core/theme/app_text_styles.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/consultation_action_dock.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_avatar_frame.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_meta_details.dart';
import 'package:omastro/features/astrologers/widgets/astrologers-profile-widgets/profile_stats_card.dart';
import '../../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../reviews/bloc/reviews_bloc.dart';
import '../../reviews/bloc/reviews_event.dart';
import '../../reviews/bloc/reviews_state.dart';
import '../../reviews/widgets/write_review_bottom_sheet.dart';
import '../widgets/connect_modal.dart';
import '../bloc/astrologers_bloc.dart';
import '../bloc/astrologers_state.dart';

class AstrologerProfilePage extends StatefulWidget {
  final Map<String, String> astrologerData;

  const AstrologerProfilePage({super.key, required this.astrologerData});

  @override
  State<AstrologerProfilePage> createState() => _AstrologerProfilePageState();
}

class _AstrologerProfilePageState extends State<AstrologerProfilePage> {
  late final String astrologerId;
  Map<String, dynamic>? _supabaseAstroData;
  bool _isLoadingSupabaseData = true;
  StreamSubscription? _presenceSubscription;
  bool _isOnlineFromPresence = false;

  @override
  void initState() {
    super.initState();
    astrologerId = widget.astrologerData['id'] ?? '';
    _isOnlineFromPresence = widget.astrologerData['is_online'] == true || widget.astrologerData['is_online'].toString() == 'true';
    _listenPresence();
    _loadSupabaseData();
    if (astrologerId.isNotEmpty) {
      context.read<ReviewsBloc>().add(LoadReviewsForAstrologer(astrologerId));
    }
  }

  @override
  void dispose() {
    _presenceSubscription?.cancel();
    super.dispose();
  }

  void _listenPresence() {
    _presenceSubscription?.cancel();
    final firebaseUid = widget.astrologerData['firebase_uid'] ?? _supabaseAstroData?['firebase_uid'] ?? '';
    if (firebaseUid.isNotEmpty) {
      _presenceSubscription = FirebaseFirestore.instance
          .collection('presence')
          .doc(firebaseUid)
          .snapshots()
          .listen((snap) {
        if (snap.exists && mounted) {
          final data = snap.data();
          setState(() {
            _isOnlineFromPresence = data?['is_online'] == true || data?['is_online'].toString() == 'true';
          });
        }
      });
    }
  }

  Future<void> _loadSupabaseData() async {
    if (astrologerId.isEmpty) return;
    try {
      final res = await Supabase.instance.client
          .from('astrologers')
          .select()
          .eq('id', astrologerId)
          .maybeSingle();
      if (res != null) {
        setState(() {
          _supabaseAstroData = res;
          _isLoadingSupabaseData = false;
        });
        _listenPresence();
      } else {
        setState(() => _isLoadingSupabaseData = false);
      }
    } catch (e) {
      print('Error loading astrologer details from Supabase: $e');
      setState(() => _isLoadingSupabaseData = false);
    }
  }

  void _handleConnect(BuildContext context) async {
    final name = widget.astrologerData['name'] ?? 'Astrologer';
    final chatRate = (widget.astrologerData['chat_rate'] is num)
        ? (widget.astrologerData['chat_rate'] as num).toDouble()
        : double.tryParse(
                widget.astrologerData['chat_rate']?.toString() ?? '5',
              ) ??
              5.0;
    final callRate = (widget.astrologerData['call_rate'] is num)
        ? (widget.astrologerData['call_rate'] as num).toDouble()
        : double.tryParse(
                widget.astrologerData['call_rate']?.toString() ?? '10',
              ) ??
              10.0;
    final videoRate = (widget.astrologerData['video_rate'] is num)
        ? (widget.astrologerData['video_rate'] as num).toDouble()
        : double.tryParse(
                widget.astrologerData['video_rate']?.toString() ?? '15',
              ) ??
              15.0;
    final isOnline = _isOnlineFromPresence;

    if (!isOnline) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Astrologer Offline'),
          content: Text(
            '$name is currently offline. Please try again later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConnectModal(
        chatRate: chatRate,
        callRate: callRate,
        videoRate: videoRate,
        astrologerId: astrologerId,
        astrologerName: name,
      ),
    );

    if (result != null && context.mounted) {
      if (result == 'chat') {
        context.push(
          '/chat-room',
          extra: {
            'id': astrologerId,
            'name': name,
            'avatarUrl': widget.astrologerData['imageUrl'] ?? '',
            'otherUid': widget.astrologerData['firebase_uid'] ?? _supabaseAstroData?['firebase_uid'] ?? '',
          },
        );
      } else if (result == 'call') {
        context.push(
          '/live-call',
          extra: {
            ...widget.astrologerData,
            'name': name,
            'image': widget.astrologerData['imageUrl'] ?? '',
            'firebase_uid': widget.astrologerData['firebase_uid'] ?? _supabaseAstroData?['firebase_uid'] ?? '',
          },
        );
      } else if (result == 'video') {
        context.push(
          '/video-call',
          extra: {
            ...widget.astrologerData,
            'name': name,
            'image': widget.astrologerData['imageUrl'] ?? '',
            'firebase_uid': widget.astrologerData['firebase_uid'] ?? _supabaseAstroData?['firebase_uid'] ?? '',
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String profileName = _supabaseAstroData?['name']?.toString() ?? widget.astrologerData['name'] ?? 'Astrologer';
    final String profileImageUrl = _supabaseAstroData?['avatar_url']?.toString() ?? widget.astrologerData['imageUrl'] ?? '';
    
    // Parse categories/specialties
    final dynamic rawCategories = _supabaseAstroData?['categories'];
    final String specialties = (rawCategories is List)
        ? rawCategories.join(', ')
        : widget.astrologerData['specialties'] ?? '';

    // Parse languages
    final dynamic rawLanguages = _supabaseAstroData?['languages'];
    final String languages = (rawLanguages is List)
        ? rawLanguages.join(', ')
        : widget.astrologerData['languages'] ?? 'English';

    final String experienceYears = _supabaseAstroData != null
        ? '${_supabaseAstroData!['experience_years']} Years'
        : widget.astrologerData['experience'] ?? '0 Years';

    final String hourlyRate = _supabaseAstroData?['price_per_minute']?.toString() ?? widget.astrologerData['rate'] ?? '0';
    final String biography = _supabaseAstroData?['bio']?.toString() ?? widget.astrologerData['bio'] ?? 'Verified Professional Astrologer.';
    final String rating = _supabaseAstroData?['rating']?.toString() ?? widget.astrologerData['rating']?.toString() ?? '5.0';
    final String totalMins = _supabaseAstroData?['total_minutes_consulted']?.toString() ?? widget.astrologerData['total_minutes_consulted']?.toString() ?? '0';

    final isOnline = _isOnlineFromPresence;

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
                        ProfileAvatarFrame(
                          imageUrl: profileImageUrl,
                          isOnline: isOnline,
                          astrologerId: astrologerId,
                        ),
                        const SizedBox(height: 16),
                        ProfileMetaDetails(
                          name: profileName,
                          specialties: specialties,
                          languages: languages,
                          experience: experienceYears,
                          ratePerMinute: hourlyRate,
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xffFAF6F0), thickness: 1.5),
                        const SizedBox(height: 16),
                        ProfileStatsCard(rating: rating, minsCount: totalMins),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                      onConnectTap: () => _handleConnect(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                              'Reviews',
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
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (context) => WriteReviewBottomSheet(
                                astrologerId: astrologerId,
                                astrologerName: profileName,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Color(0xffE4A834),
                          ),
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
                          final reviews = state.reviews[astrologerId] ?? [];

                          if (reviews.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Text(
                                'No reviews yet. Be the first to review!',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final review = reviews[index];

                              String formattedTime;
                              final difference = DateTime.now().difference(
                                review.timestamp,
                              );
                              if (difference.inMinutes < 60) {
                                formattedTime =
                                    '${difference.inMinutes} mins ago';
                              } else if (difference.inHours < 24) {
                                formattedTime =
                                    '${difference.inHours} hours ago';
                              } else {
                                formattedTime = '${difference.inDays} days ago';
                              }

                              return _buildReviewItem(
                                review.userName,
                                review.rating,
                                review.comment,
                                formattedTime,
                                review.reviewerAvatar,
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
    String? avatarUrl,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[200],
          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
              ? NetworkImage(avatarUrl)
              : null,
          child: (avatarUrl == null || avatarUrl.isEmpty)
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
          ),
        ),
      ],
    );
  }
}
