import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:omastro/core/responsive/responsive_provider.dart';
import 'package:omastro/core/theme/app_colors.dart';
import 'package:omastro/core/widgets/app_astrologers_card.dart';

class OnlineAstrologersSection extends StatelessWidget {
  const OnlineAstrologersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    final List<Map<String, dynamic>> onlineList = [
      {
        'name': 'Astro Priya',
        'image': 'assets/images/priya.jpg',
        'specialty': 'Tarot, Palmistry',
        'rating': 4.9,
        'price': 25,
      },
      {
        'name': 'Yogini Meera',
        'image': 'assets/images/meera.jpg',
        'specialty': 'Vedic, Kundli',
        'rating': 5.0,
        'price': 30,
      },
      {
        'name': 'Swami Anand',
        'image': 'assets/images/anand.jpg',
        'specialty': 'Vastu, Numerology',
        'rating': 4.7,
        'price': 35,
      },
    ];

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

        SizedBox(
          height: responsive.featuredCardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            padding: EdgeInsets.symmetric(horizontal: responsive.scale(2)),
            itemCount: onlineList.length,
            separatorBuilder: (_, __) => SizedBox(width: responsive.scale(12)),
            itemBuilder: (context, index) {
              final astrologer = onlineList[index];

              return FeaturedAstrologerCard(
                name: astrologer['name'],
                imageUrl: astrologer['image'],
                specialty: astrologer['specialty'],
                rating: astrologer['rating'],
                pricePerMin: astrologer['price'],
                isOnline: true,
                onTap: () {
                  context.push(
                    '/astrologer-profile',
                    extra: {
                      'name': astrologer['name'],
                      'imageUrl': astrologer['image'],
                      'specialties': astrologer['specialty'],
                      'languages': 'English, Hindi',
                      'experience': '5 Years',
                      'rate': astrologer['price'].toString(),
                      'bio':
                          'Live advisor available to guide your consultation right now.',
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
