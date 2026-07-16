import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_category_card.dart';

class HomeCategoryGrid extends StatelessWidget {
  const HomeCategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
    // Definitive list configuration matching the design items
    final List<Map<String, dynamic>> categories = [
      {'label': 'Love', 'icon': Icons.favorite_border_rounded},
      {'label': 'Career', 'icon': Icons.work_outline_rounded},
      {'label': 'Marriage', 'icon': Icons.people_outline_rounded},
      {'label': 'Tarot', 'icon': Icons.style_outlined},
      {'label': 'Kundli', 'icon': Icons.menu_book_rounded},
      {'label': 'Horoscope', 'icon': Icons.wb_twilight_rounded},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: responsive.scale(8, min: 6, max: 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Text
          Text(
            'Explore Categories',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: responsive.font(16, min: 14, max: 18),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: responsive.scale(12, min: 10, max: 16)),

          // Grid Container Track
          GridView.builder(
            shrinkWrap:
                true, // Allows the grid to sit cleanly inside the parent Column layout
            physics:
                const NeverScrollableScrollPhysics(), // Disables inner grid fight with overall page scroll
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsive.categoryColumns,
              crossAxisSpacing: responsive.scale(12, min: 8, max: 16),
              mainAxisSpacing: responsive.scale(12, min: 8, max: 16),
              childAspectRatio: responsive.isMobile ? 0.95 : 1.05,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final item = categories[index];
              return AppCategoryCard(
                icon: item['icon'],
                label: item['label'],
                onTap: () {
                  context.go('/hub-list/${item['label']}');
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
