import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/core/widgets/app_astrologers_card.dart';
import '../../../core/theme/app_colors.dart';

class TopAstrologersSection extends StatelessWidget {
  const TopAstrologersSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary mock list simulating live database entries for Phase 1
    final List<Map<String, dynamic>> onlineList = [
      {
        'name': 'Astral Rohan',
        'image':
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200&auto=format&fit=crop',
        'specialty': 'Vedic, Kundli',
        'rating': 4.8,
        'price': 25,
      },
      {
        'name': 'Ananya Shastri',
        'image':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
        'specialty': 'Tarot, Palmistry',
        'rating': 4.9,
        'price': 30,
      },
      {
        'name': 'Guru Mahesh',
        'image':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
        'specialty': 'Vastu, Numerology',
        'rating': 4.7,
        'price': 20,
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
              'Top Astrologers',
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
