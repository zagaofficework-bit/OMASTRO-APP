import 'package:flutter/material.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import '../../../core/theme/app_colors.dart';

class StoreCategoryGrid extends StatelessWidget {
  final VoidCallback onCardTap;

  const StoreCategoryGrid({super.key, required this.onCardTap});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
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
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: GridView.builder(
        shrinkWrap:
            true, // Crucial: Allows the grid to size itself to content inside SingleChildScrollView
        physics:
            const NeverScrollableScrollPhysics(), // Disables inner scrolling so it scrolls with parent column smoothly
        itemCount: categories.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsive.storeColumns,
          crossAxisSpacing: responsive.scale(12, min: 10, max: 16),
          mainAxisSpacing: responsive.scale(12, min: 10, max: 16),
          childAspectRatio: responsive.isMobile ? 0.82 : 0.88,
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
    final responsive = ResponsiveProvider.of(context);

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
                padding: EdgeInsets.all(responsive.scale(10, min: 8, max: 12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: responsive.font(12.5, min: 11.5, max: 14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: responsive.scale(2, min: 2, max: 4)),
                    Text(
                      count,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: responsive.font(10.5, min: 9.5, max: 12),
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
