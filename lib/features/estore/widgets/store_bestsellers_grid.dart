import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StoreBestsellersGrid extends StatelessWidget {
  final VoidCallback onCardTap;

  const StoreBestsellersGrid({super.key, required this.onCardTap});

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(), // Passes scroll gestures back to the page container parent
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 0.82,
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
                    const SizedBox(height: 4.0),

                    // Link action tag matching "Buy now ↗" exactly from image layout
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Buy now ',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.0,
                            fontWeight: FontWeight.w500,
                            color: Color(
                              0xffC7922E,
                            ), // Brand saffron accent token
                          ),
                        ),
                        Icon(
                          Icons
                              .open_in_new_rounded, // Minimalistic clean launch chevron arrow icon
                          size: 11.0,
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
