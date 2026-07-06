import 'package:flutter/material.dart';
import 'package:omastro/core/theme/app_colors.dart';
import 'package:omastro/core/theme/app_spacing.dart';
import 'package:omastro/core/theme/app_text_styles.dart';
import 'package:omastro/core/widgets/search_bar.dart';
import '../widgets/astrologers_list_view.dart';
import '../widgets/category_filter_chips.dart';

class AstrologerPage extends StatefulWidget {
  final String? initialCategory;
  const AstrologerPage({super.key, this.initialCategory = 'All'});

  @override
  State<AstrologerPage> createState() => _AstrologerPageState();
}

class _AstrologerPageState extends State<AstrologerPage> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
  }

  // --- Master Testing Dataset Local Track with high-res Unsplash portrait assets ---
  final List<Map<String, dynamic>> _allAstrologers = [
    {
      'name': 'Yogini Meera',
      'image':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=400&auto=format&fit=crop',
      'specialties': ['Palmistry', 'Crystal Healing', 'Love'],
      'experience': 12,
      'languages': ['English'],
      'rating': 5.0,
      'price': 30,
      'isOnline': true,
    },
    {
      'name': 'Astro Priya',
      'image':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=400&auto=format&fit=crop',
      'specialties': ['Tarot Reading', 'Numerology', 'Tarot', 'Career'],
      'experience': 8,
      'languages': ['English', 'Hindi', 'Tamil'],
      'rating': 4.9,
      'price': 25,
      'isOnline': true,
    },
    {
      'name': 'Acharya Shivam',
      'image':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=400&auto=format&fit=crop',
      'specialties': ['Vedic Astrology', 'Vastu', 'Kundli', 'Marriage'],
      'experience': 15,
      'languages': ['English', 'Hindi'],
      'rating': 4.8,
      'price': 20,
      'isOnline': true,
    },
    {
      'name': 'Swami Anand',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=400&auto=format&fit=crop',
      'specialties': ['Vedic', 'Gemology', 'Kundli'],
      'experience': 20,
      'languages': ['Hindi', 'Marathi'],
      'rating': 4.7,
      'price': 35,
      'isOnline': false,
    },
  ];

  List<Map<String, dynamic>> _getFilteredAstrologers() {
    if (_selectedCategory == 'All') {
      return _allAstrologers;
    }
    return _allAstrologers.where((astrologer) {
      final List<String> specialties = List<String>.from(
        astrologer['specialties'],
      );
      return specialties.any(
        (s) => s.toLowerCase() == _selectedCategory.toLowerCase(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredAstrologers();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSpacing.heightXl,
                      AppSpacing.heightXl,
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          left: 14.0,
                          right: 8.0,
                        ),
                        child: Text(
                          'Discover Your Astrologer',
                          style: AppTextStyles.displayLarge02,
                        ),
                      ),
                      AppSpacing.heightMd,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: AppSearchBar(),
                      ),
                      const SizedBox(height: 16.0),
                      CategoryFilterChips(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: Stack(
            children: [
              Positioned.fill(
                child: AstrologersListView(
                  astrologers: filteredList,
                ), // Passes the clean list down
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(height: 120),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
