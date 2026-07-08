import 'package:flutter/material.dart';
import 'package:omastro/core/theme/app_colors.dart';
import 'package:omastro/core/theme/app_spacing.dart';
import 'package:omastro/core/theme/app_text_styles.dart';
import 'package:omastro/core/widgets/search_bar.dart';
import '../widgets/astrologers_list_view.dart';
import '../widgets/category_filter_chips.dart';
import 'package:go_router/go_router.dart';
import '../astrologers_data.dart';

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

  // --- Master Testing Dataset Local Track with downloaded asset images ---
  final List<Map<String, dynamic>> _allAstrologers = masterAstrologers;

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 76),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home'); // Fallback if no page to pop
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          padding: const EdgeInsets.all(10.0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Astrologers',
                        style: AppTextStyles.displayLarge02.copyWith(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AstrologersListView(
                      astrologers: filteredList,
                    ),
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
          ],
    ),
    ),
    );
  }
}
