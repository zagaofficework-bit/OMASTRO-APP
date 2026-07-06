import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StoreCategoryGrid extends StatelessWidget {
  final VoidCallback onCardTap;

  const StoreCategoryGrid({super.key, required this.onCardTap});

  @override
  Widget build(BuildContext context) {
    // Local data configuration array representing your store catalog categories
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Rudraksha Bracelets',
        'count': '24 items',
        'image':
            'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?q=80&w=300&auto=format&fit=crop', // Substitute with your local asset paths if preferred
      },
      {
        'title': 'Pendants',
        'count': '32 items',
        'image':
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Idols',
        'count': '48 items',
        'image':
            'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Malas',
        'count': '16 items',
        'image':
            'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Siddh Malas',
        'count': '12 items',
        'image':
            'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Crystal Bracelets',
        'count': '38 items',
        'image':
            'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Shankha',
        'count': '48 items',
        'image':
            'https://images.unsplash.com/photo-1605100804763-247f67b3557e?q=80&w=300&auto=format&fit=crop',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap:
            true, // Crucial: Allows the grid to size itself to content inside SingleChildScrollView
        physics:
            const NeverScrollableScrollPhysics(), // Disables inner scrolling so it scrolls with parent column smoothly
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio:
              0.82, // Tailored aspect balance matching the card dimensions in E-store page.jpg
        ),
        itemBuilder: (context, index) {
          final item = categories[index];
          return _CategoryCard(
            title: item['title'],
            count: item['count'],
            imageUrl: item['image'],
            onTap: onCardTap,
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String count;
  final String imageUrl;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.count,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xffEFEAE2), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: onTap, // Executes external website launcher route
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Container Block
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xff121212,
                    ), // Deep dark backing placeholder
                  ),
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),

              // 2. Info Footer Label Deck
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      count,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
