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

  @override
  void didUpdateWidget(AstrologerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory && widget.initialCategory != null) {
      setState(() {
        _selectedCategory = widget.initialCategory!;
      });
    }
    if (widget.initialSearchQuery != oldWidget.initialSearchQuery && widget.initialSearchQuery != null) {
      setState(() {
        _searchQuery = widget.initialSearchQuery!;
      });
    }
  }

  List<String> _extractList(dynamic input) {
    if (input == null) return [];
    if (input is List) return input.map((e) => e.toString()).toList();
    if (input is String) return [input];
    return [];
  }

  List<Map<String, dynamic>> _getFilteredAstrologers(
    List<Map<String, dynamic>> allAstrologers,
  ) {
    List<Map<String, dynamic>> filtered = allAstrologers;
    if (_selectedCategory != 'All') {
      filtered = filtered.where((astrologer) {
        final List<String> specialties = _extractList(astrologer['categories']);
        return specialties.any(
          (s) => s.toLowerCase() == _selectedCategory.toLowerCase(),
        );
      }).toList();
    }
    
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((astrologer) {
        final name = (astrologer['name'] ?? '').toString().toLowerCase();
        final bio = (astrologer['bio'] ?? astrologer['about'] ?? '').toString().toLowerCase();
        final categories = _extractList(astrologer['categories']);
        final skills = _extractList(astrologer['skills']);
        final languages = _extractList(astrologer['languages']);

        final matchesName = name.contains(query);
        final matchesBio = bio.contains(query);
        final matchesCategory = categories.any((c) => c.toLowerCase().contains(query));
        final matchesSkill = skills.any((s) => s.toLowerCase().contains(query));
        final matchesLang = languages.any((l) => l.toLowerCase().contains(query));

        return matchesName || matchesBio || matchesCategory || matchesSkill || matchesLang;
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
