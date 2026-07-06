import 'package:flutter/material.dart';
import 'package:omastro/features/astrologers/screen/astrologer_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_category_card.dart';

class HomeCategoryGrid extends StatelessWidget {
  const HomeCategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Text
          const Text(
            'Explore Categories',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12.0),

          // Grid Container Track
          GridView.builder(
            shrinkWrap:
                true, // Allows the grid to sit cleanly inside the parent Column layout
            physics:
                const NeverScrollableScrollPhysics(), // Disables inner grid fight with overall page scroll
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 items per row matching visual layout
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.95, // Maintains balanced square layout bounds
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final item = categories[index];
              return AppCategoryCard(
                icon: item['icon'],
                label: item['label'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AstrologerPage(
                        initialCategory: item['label']
                            .toString(), // 👈 Pass the exact string category name here dynamically (e.g., item['title'])
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
