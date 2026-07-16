import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:omastro/core/responsive/responsive_provider.dart';
import 'package:omastro/core/theme/app_colors.dart';
import 'package:omastro/core/widgets/app_astrologers_card.dart';
import 'package:omastro/features/astrologers/bloc/astrologers_bloc.dart';
import 'package:omastro/features/astrologers/bloc/astrologers_state.dart';

class OnlineAstrologersSection extends StatelessWidget {
  const OnlineAstrologersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return BlocBuilder<AstrologersBloc, AstrologersState>(
      builder: (context, state) {
        List<Map<String, dynamic>> onlineList = [];
        if (state is AstrologersFollowingState) {
          onlineList = state.astrologers
              .where((a) => a['is_online'] == true)
              .toList();
        }

        if (onlineList.isEmpty &&
            state is AstrologersFollowingState &&
            !state.isLoading) {
          return const SizedBox.shrink(); // Hide section if no online astrologers
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Online now',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: responsive.font(16, min: 14, max: 18),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.scale(10),
                      vertical: responsive.scale(6),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    context.push('/hub-list');
                  },
                  child: Text(
                    'See all',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: responsive.font(13),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: responsive.scale(8)),

            if (state is AstrologersFollowingState && state.isLoading && onlineList.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                height: responsive.featuredCardHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.scale(2),
                  ),
                  itemCount: onlineList.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(width: responsive.scale(12)),
                  itemBuilder: (context, index) {
                    final astrologer = onlineList[index];

                    return FeaturedAstrologerCard(
                      name: astrologer['name'] ?? 'Unknown',
                      imageUrl: astrologer['avatar_url'] ?? '',
                      astrologerId: astrologer['id']?.toString(),
                      specialty:
                          (astrologer['categories'] as List?)?.join(', ') ?? '',
                      rating: (astrologer['rating'] ?? 5.0).toDouble(),
                      pricePerMin: (astrologer['price_per_minute'] ?? 0)
                          .toInt(),
                      isOnline: astrologer['is_online'] ?? false,
                      onTap: () {
                        context.push(
                          '/astrologer-profile',
                          extra: {
                            'id': astrologer['id']?.toString() ?? '',
                            'firebase_uid':
                                astrologer['firebase_uid']?.toString() ?? '',
                            'name': astrologer['name']?.toString() ?? '',
                            'imageUrl':
                                astrologer['avatar_url']?.toString() ?? '',
                            'specialties':
                                (astrologer['categories'] as List?)?.join(
                                  ', ',
                                ) ??
                                '',
                            'languages':
                                (astrologer['languages'] as List?)?.join(
                                  ', ',
                                ) ??
                                '',
                            'experience':
                                '${astrologer['experience_years']} Years',
                            'rate':
                                astrologer['price_per_minute']?.toString() ??
                                '0',
                            'chat_rate':
                                astrologer['chat_rate']?.toString() ?? '5',
                            'call_rate':
                                astrologer['call_rate']?.toString() ?? '10',
                            'video_rate':
                                astrologer['video_rate']?.toString() ?? '15',
                            'is_online':
                                astrologer['is_online']?.toString() ?? 'false',
                            'total_minutes_consulted':
                                astrologer['total_minutes_consulted']
                                    ?.toString() ??
                                '0',
                            'bio': astrologer['bio']?.toString() ?? '',
                          },
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
