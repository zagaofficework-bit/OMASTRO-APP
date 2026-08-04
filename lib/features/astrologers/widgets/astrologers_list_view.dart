import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';

import 'astrologer_list_card.dart';

class AstrologersListView extends StatelessWidget {
  final List<Map<String, dynamic>> astrologers;
  final double bottomPadding;
  final Future<void> Function()? onRefresh;

  const AstrologersListView({
    super.key,
    required this.astrologers,
    this.bottomPadding = 24,
    this.onRefresh,
  });

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

    final listView = ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: responsive.horizontalPadding,
        right: responsive.horizontalPadding,
        top: responsive.scale(12, min: 10, max: 16),
        bottom: bottomPadding,
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
                  'id': currentItem['id']?.toString() ?? '',
                  'firebase_uid': currentItem['firebase_uid']?.toString() ?? '',
                  'name': currentItem['name']?.toString() ?? '',
                  'imageUrl': currentItem['avatar_url']?.toString() ?? '',
                  'specialties': (currentItem['categories'] as List? ?? [])
                      .join(', '),
                  'languages': (currentItem['languages'] as List? ?? []).join(
                    ', ',
                  ),
                  'experience': '${currentItem['experience_years'] ?? 0} Years',
                  'rate': currentItem['price_per_minute']?.toString() ?? '0',
                  'chat_rate': currentItem['chat_rate']?.toString() ?? '5',
                  'call_rate': currentItem['call_rate']?.toString() ?? '10',
                  'video_rate': currentItem['video_rate']?.toString() ?? '15',
                  'is_online': currentItem['is_online']?.toString() ?? 'false',
                  'total_minutes_consulted':
                      currentItem['total_minutes_consulted']?.toString() ?? '0',
                  'bio':
                      currentItem['bio']?.toString() ??
                      'Verified expert specializing in Astrology.',
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
              chatRate: (currentItem['chat_rate'] ?? 5.0).toDouble(),
              callRate: (currentItem['call_rate'] ?? 10.0).toDouble(),
              videoRate: (currentItem['video_rate'] ?? 15.0).toDouble(),
              astrologerId: currentItem['id']?.toString() ?? '',
              onChatTap: () {
                context.push(
                  '/chat-room',
                  extra: {
                    'id': currentItem['id']?.toString() ?? '',
                    'firebase_uid': currentItem['firebase_uid']?.toString() ?? '',
                    'name': currentItem['name'],
                    'avatarUrl': currentItem['avatar_url'] ?? '',
                  },
                );
              },
              onCallTap: () {
                if (currentItem['is_online'] != true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${currentItem['name'] ?? 'Astrologer'} is currently offline.')),
                  );
                  return;
                }
                context.push(
                  '/live-call',
                  extra: {
                    ...currentItem,
                    'image': currentItem['avatar_url'] ?? '',
                  },
                );
              },
              onVideoTap: () {
                if (currentItem['is_online'] != true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${currentItem['name'] ?? 'Astrologer'} is currently offline.')),
                  );
                  return;
                }
                context.push(
                  '/video-call',
                  extra: {
                    ...currentItem,
                    'image': currentItem['avatar_url'] ?? '',
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(onRefresh: onRefresh!, child: listView);
    }

    return listView;
  }
}
