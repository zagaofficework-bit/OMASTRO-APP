import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AstrologerCategoryGrid extends StatelessWidget {
  final Function(String categoryName) onCategoryTap;

  const AstrologerCategoryGrid({super.key, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    // Exact structural config matching data rows in astrologers_search page.jpg
    final List<Map<String, dynamic>> categoryItems = [
      {
        'title': 'Numerology',
        'subtitle': 'Decode your numbers',
        'icon': Icons.numbers_rounded,
      },
      {
        'title': 'Psychic',
        'subtitle': 'Intuitive guidance',
        'icon': Icons.visibility_outlined,
      },
      {
        'title': 'Tarot',
        'subtitle': 'Card readings',
        'icon': Icons.local_fire_department_outlined,
      },
      {
        'title': 'Vedic',
        'subtitle': 'Ancient wisdom',
        'icon': Icons.menu_book_outlined,
      },
      {
        'title': 'Life Coach',
        'subtitle': 'Personal growth',
        'icon': Icons.explore_outlined,
      },
      {
        'title': 'Palmistry',
        'subtitle': 'Hand analysis',
        'icon': Icons.front_hand_outlined,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Flows seamlessly under the scroll wrapper
      itemCount: categoryItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.0,
        mainAxisSpacing: 14.0,
        childAspectRatio:
            1.15, // Perfect squarish proportions matching the layout reference image
      ),
      itemBuilder: (context, index) {
        final item = categoryItems[index];
        return _CategoryHubCard(
          title: item['title'],
          subtitle: item['subtitle'],
          icon: item['icon'],
          onTap: () => onCategoryTap(item['title']),
        );
      },
    );
  }
}

class _CategoryHubCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryHubCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0xffEFEAE2), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Minimalistic circular container backplate for the icon accent
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xffFDF8F2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: const Color(
                      0xffD4A437,
                    ), // Soft gold brand identifier
                    size: 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
