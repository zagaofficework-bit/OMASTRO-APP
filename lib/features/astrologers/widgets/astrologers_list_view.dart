import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';

import 'astrologers_list_card.dart';

class AstrologersListView extends StatelessWidget {
  final List<Map<String, dynamic>> astrologers;

  const AstrologersListView({super.key, required this.astrologers});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    if (astrologers.isEmpty) {
      return const Center(
        child: Text(
          'No astrologers available in this category.',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.horizontalPadding,
        vertical: responsive.scale(12, min: 10, max: 16),
      ),
      itemCount: astrologers.length,
      itemBuilder: (context, index) {
        final currentItem = astrologers[index];

        return Padding(
          padding: EdgeInsets.only(
            bottom: responsive.scale(16, min: 12, max: 20),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context.push(
                '/astrologer-profile',
                extra: {
                  'name': currentItem['name']?.toString() ?? '',
                  'imageUrl': currentItem['avatar_url']?.toString() ?? '',
                  'specialties': (currentItem['categories'] as List? ?? [])
                      .join(', '),
                  'languages': (currentItem['languages'] as List? ?? []).join(
                    ', ',
                  ),
                  'experience': '${currentItem['experience_years'] ?? 0} Years',
                  'rate': currentItem['price_per_minute']?.toString() ?? '0',
                  'bio': currentItem['bio']?.toString() ?? 'Verified expert specializing in Astrology.',
                },
              );
            },
            child: AstrologerListCard(
              name: currentItem['name'] ?? 'Unknown',
              imageUrl: currentItem['avatar_url'] ?? '',
              specialties: List<String>.from(currentItem['categories'] ?? []),
              experienceYears: currentItem['experience_years'] ?? 0,
              languages: List<String>.from(currentItem['languages'] ?? []),
              rating: (currentItem['rating'] ?? 5.0).toDouble(),
              pricePerMin: (currentItem['price_per_minute'] ?? 0).toInt(),
              isOnline: currentItem['is_online'] ?? false,
              onChatTap: () {
                context.push(
                  '/chat-room',
                  extra: {
                    'id':
                        'chat_${currentItem['name'].toString().toLowerCase().replaceAll(' ', '_')}',
                    'name': currentItem['name'],
                  },
                );
              },
              onCallTap: () => context.push('/live-call', extra: currentItem),
              onVideoTap: () => context.push('/video-call', extra: currentItem),
            ),
          ),
        );
      },
    );
  }
}
