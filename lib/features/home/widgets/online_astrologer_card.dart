import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/core/widgets/app_astrologers_card.dart';
import '../../../core/theme/app_colors.dart';

class OnlineAstrologersSection extends StatelessWidget {
  const OnlineAstrologersSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary mock list simulating live database entries for Phase 1
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
        // --- Section Header Title Block ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Online now',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/hub-list');
              },
              child: const Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),

        // --- Horizontal Scrolling List Layout ---
        SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: onlineList.length,
            itemBuilder: (context, index) {
              final currentAstrologer = onlineList[index];

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: FeaturedAstrologerCard(
                  name: currentAstrologer['name'],
                  imageUrl: currentAstrologer['image'],
                  specialty: currentAstrologer['specialty'],
                  rating: currentAstrologer['rating'],
                  pricePerMin: currentAstrologer['price'],
                  isOnline: true,
                  onTap: () {
                    context.push(
                      '/astrologer-profile',
                      extra: {
                        'name': currentAstrologer['name']?.toString() ?? '',
                        'imageUrl':
                            currentAstrologer['image']?.toString() ?? '',
                        'specialties':
                            currentAstrologer['specialty']?.toString() ?? '',
                        'languages': 'English, Hindi',
                        'experience': '5 Years',
                        'rate':
                            currentAstrologer['price']?.toString() ??
                            '0', // 👈 .toString() ensures it's a String, not an int
                        'bio':
                            'Live advisor available to guide your consultation right now.',
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
