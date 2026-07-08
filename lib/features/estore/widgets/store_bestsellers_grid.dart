import 'package:flutter/material.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import '../../../core/theme/app_colors.dart';

class StoreBestsellersGrid extends StatelessWidget {
  final VoidCallback onCardTap;

  const StoreBestsellersGrid({super.key, required this.onCardTap});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
    // Dynamic mock dataset mapping the specific product items shown in E-store page.jpg
    final List<Map<String, dynamic>> products = [
      {
        'title': 'Trishul Rudraksha Pendant',
        'image':
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Shiv Kawach',
        'image':
            'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Om Rudraksha Pendant',
        'image':
            'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?q=80&w=300&auto=format&fit=crop',
      },
      {
        'title': 'Maa Durga Pendant',
        'image':
            'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?q=80&w=300&auto=format&fit=crop',
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(), // Passes scroll gestures back to the page container parent
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsive.storeColumns,
          crossAxisSpacing: responsive.scale(12, min: 10, max: 16),
          mainAxisSpacing: responsive.scale(12, min: 10, max: 16),
          childAspectRatio: responsive.isMobile ? 0.82 : 0.88,
        ),
        itemBuilder: (context, index) {
          final item = products[index];
          return _ProductCard(
            title: item['title'],
            imageUrl: item['image'],
            onTap: onCardTap,
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _ProductCard({
    required this.title,
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
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Viewport Frame
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xff121212),
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),

              // 2. Info Card Text deck
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
                    SizedBox(height: responsive.scale(4, min: 3, max: 6)),

                    // Link action tag matching "Buy now ↗" exactly from image layout
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Buy now ',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: responsive.font(11, min: 10, max: 12),
                            fontWeight: FontWeight.w500,
                            color: Color(
                              0xffC7922E,
                            ), // Brand saffron accent token
                          ),
                        ),
                        Icon(
                          Icons
                              .open_in_new_rounded, // Minimalistic clean launch chevron arrow icon
                          size: responsive.scale(11, min: 10, max: 13),
                          color: const Color(0xffC7922E),
                        ),
                      ],
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
