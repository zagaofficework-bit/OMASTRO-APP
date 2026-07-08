import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/core/theme/app_colors.dart';
import 'package:omastro/core/theme/app_text_styles.dart';
import 'package:omastro/core/widgets/search_bar.dart';
import '../widgets/astrologer_category_grid.dart';

class AstrologerCategoryPage extends StatelessWidget {
  const AstrologerCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 76,
                  ), // Breathing room clearance offset for your global TopBar layout
                  // --- 1. Dynamic Sub-Navigation Header ---
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
                        'Astrology Categories',
                        style: AppTextStyles.displayLarge02.copyWith(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // --- 2. Centralized Search Input Target ---
                  AppSearchBar(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 3. Primary Hub Category Interactive Selection Blocks ---
                      AstrologerCategoryGrid(
                        onCategoryTap: (categoryName) {
                          // Navigates directly to your pre-filtered list view using GoRouter path parameters
                          context.push('/hub-list/$categoryName');
                        },
                      ),
                      const SizedBox(
                        height: 120,
                      ), // Essential navigation cushion spacing padding safety layout track
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
