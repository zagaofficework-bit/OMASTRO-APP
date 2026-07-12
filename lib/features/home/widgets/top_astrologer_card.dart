import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:omastro/core/responsive/responsive_provider.dart';
import 'package:omastro/core/theme/app_colors.dart';
import 'package:omastro/core/widgets/app_astrologers_card.dart';
import 'package:omastro/features/astrologers/bloc/astrologers_bloc.dart';
import 'package:omastro/features/astrologers/bloc/astrologers_state.dart';

class TopAstrologersSection extends StatelessWidget {
  const TopAstrologersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return BlocBuilder<AstrologersBloc, AstrologersState>(
      builder: (context, state) {
        List<Map<String, dynamic>> topAstrologers = [];
        if (state is AstrologersFollowingState) {
          topAstrologers = state.astrologers;
          // You could add logic here to filter or sort top astrologers, e.g. based on rating
        }

        if (topAstrologers.isEmpty && state is AstrologersFollowingState && !state.isLoading) {
           return const SizedBox.shrink(); // Hide section if no astrologers
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Top Astrologers',
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

            if (state is AstrologersFollowingState && state.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                height: responsive.featuredCardHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.symmetric(horizontal: responsive.scale(2)),
                  itemCount: topAstrologers.length,
                  separatorBuilder: (_, _) => SizedBox(width: responsive.scale(12)),
                  itemBuilder: (context, index) {
                    final astrologer = topAstrologers[index];

                    return FeaturedAstrologerCard(
                      name: astrologer['name'] ?? 'Unknown',
                      imageUrl: astrologer['avatar_url'] ?? '',
                      specialty: (astrologer['categories'] as List?)?.join(', ') ?? '',
                      rating: (astrologer['rating'] ?? 5.0).toDouble(),
                      pricePerMin: (astrologer['price_per_minute'] ?? 0).toInt(),
                      isOnline: astrologer['is_online'] ?? false,
                      onTap: () {
                        context.push(
                          '/astrologer-profile',
                          extra: {
                            'name': astrologer['name']?.toString() ?? '',
                            'imageUrl': astrologer['avatar_url']?.toString() ?? '',
                            'specialties': (astrologer['categories'] as List?)?.join(', ') ?? '',
                            'languages': (astrologer['languages'] as List?)?.join(', ') ?? '',
                            'experience': '${astrologer['experience_years']} Years',
                            'rate': astrologer['price_per_minute']?.toString() ?? '0',
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
