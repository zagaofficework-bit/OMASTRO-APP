import 'package:flutter/material.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import 'package:omastro/core/theme/app_colors.dart';
import 'package:omastro/core/theme/app_text_styles.dart';
import 'package:omastro/core/widgets/search_bar.dart';
import '../widgets/astrologers_list_view.dart';
import '../widgets/category_filter_chips.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omastro/features/astrologers/bloc/astrologers_bloc.dart';
import 'package:omastro/features/astrologers/bloc/astrologers_state.dart';
import 'package:omastro/features/astrologers/bloc/astrologers_event.dart';

class AstrologerPage extends StatefulWidget {
  final String? initialCategory;
  final String? initialSearchQuery;
  const AstrologerPage({super.key, this.initialCategory = 'All', this.initialSearchQuery});

  @override
  State<AstrologerPage> createState() => _AstrologerPageState();
}

class _AstrologerPageState extends State<AstrologerPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _searchQuery = widget.initialSearchQuery ?? '';
    context.read<AstrologersBloc>().add(LoadAstrologers());
  }

  List<Map<String, dynamic>> _getFilteredAstrologers(
    List<Map<String, dynamic>> allAstrologers,
  ) {
    List<Map<String, dynamic>> filtered = allAstrologers;
    if (_selectedCategory != 'All') {
      filtered = filtered.where((astrologer) {
        final List<String> specialties = List<String>.from(
          astrologer['categories'] ?? [],
        );
        return specialties.any(
          (s) => s.toLowerCase() == _selectedCategory.toLowerCase(),
        );
      }).toList();
    }
    
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((astrologer) {
        final name = (astrologer['name'] ?? '').toString().toLowerCase();
        final List<String> specialties = List<String>.from(
          astrologer['categories'] ?? [],
        );
        return name.contains(query) || specialties.any((s) => s.toLowerCase().contains(query));
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AstrologersBloc, AstrologersState>(
      builder: (context, state) {
        List<Map<String, dynamic>> allAstrologers = [];
        if (state is AstrologersFollowingState) {
          allAstrologers = state.astrologers;
        }

        final filteredList = _getFilteredAstrologers(allAstrologers);
        final responsive = ResponsiveProvider.of(context);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: responsive.pageConstraints(),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: responsive.topBarHeight - 8),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go(
                                      '/home',
                                    ); // Fallback if no page to pop
                                  }
                                },
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: AppColors.textPrimary,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.surface,
                                  padding: EdgeInsets.all(
                                    responsive.scale(10, min: 8, max: 12),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: responsive.scale(12, min: 8, max: 16),
                              ),
                              Text(
                                'Astrologers',
                                style: AppTextStyles.displayLarge02.copyWith(
                                  fontFamily: 'PlayfairDisplay',
                                  fontSize: responsive.font(
                                    24,
                                    min: 22,
                                    max: 30,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: responsive.scale(20, min: 14, max: 24),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSearchBar(
                            initialValue: _searchQuery,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                          ),
                          SizedBox(
                            height: responsive.scale(16, min: 12, max: 20),
                          ),
                          CategoryFilterChips(
                            selectedCategory: _selectedCategory,
                            onCategorySelected: (category) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                          SizedBox(
                            height: responsive.scale(8, min: 6, max: 12),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: AstrologersListView(
                        astrologers: filteredList,
                        bottomPadding:
                            MediaQuery.of(context).padding.bottom + 90,
                        onRefresh: () async {
                          context.read<AstrologersBloc>().add(
                            LoadAstrologers(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
