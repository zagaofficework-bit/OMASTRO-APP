import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ConsultationHistoryPage extends StatelessWidget {
  const ConsultationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for consultations
    final List<Map<String, dynamic>> history = [
      {
        'name': 'Astro Priya',
        'type': 'Chat',
        'duration': '15 mins',
        'rate': '₹25/min',
        'total': '₹375',
        'date': '05 July 2026, 11:15 AM',
        'status': 'Completed',
        'image': 'assets/images/priya.jpg',
      },
      {
        'name': 'Yogini Meera',
        'type': 'Call',
        'duration': '10 mins',
        'rate': '₹30/min',
        'total': '₹300',
        'date': '02 July 2026, 04:30 PM',
        'status': 'Completed',
        'image': 'assets/images/meera.jpg',
      },
      {
        'name': 'Acharya Shivam',
        'type': 'Video Call',
        'duration': '8 mins',
        'rate': '₹20/min',
        'total': '₹160',
        'date': '28 June 2026, 02:10 PM',
        'status': 'Completed',
        'image': 'assets/images/shivam.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profile');
              }
            },
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: Text(
          'History',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            final isChat = item['type'] == 'Chat';
            final isVideo = item['type'] == 'Video Call';

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
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
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.background,
                        backgroundImage: AssetImage(item['image']),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: AppTextStyles.headingSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['date'],
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.onlineGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['status'],
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.onlineGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isChat
                                ? Icons.chat_bubble_outline_rounded
                                : (isVideo ? Icons.videocam_outlined : Icons.call_outlined),
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${item['type']} (${item['duration']})',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ],
                      ),
                      Text(
                        item['total'],
                        style: AppTextStyles.priceHighlight,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
