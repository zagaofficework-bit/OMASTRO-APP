import 'package:flutter/material.dart';
import 'package:omastro/features/estore/widgets/store_bestsellers_grid.dart';
import 'package:omastro/features/estore/widgets/store_category_grid.dart';
import 'package:omastro/features/estore/widgets/store_feature_row.dart';
import 'package:omastro/features/estore/widgets/store_header.dart';
import 'package:omastro/features/estore/widgets/tore_footer_button.dart';
import '../../../core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_text_styles.dart';

// lib/features/estore/screen/estore_page.dart

class EStorePage extends StatelessWidget {
  const EStorePage({super.key});

  Future<void> _launchStoreWebsite() async {
    final Uri url = Uri.parse('https://omrudrakshajewels.com/');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching store link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 80,
              ), // Clear space for your floating AppTopBar

              const StoreHeader(),
              const SizedBox(height: 16),

              const StoreFeaturesRow(),
              const SizedBox(height: 24),

              // --- Category Section ---
              // const SectionHeader(title: 'Shop by category'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Shop by category', style: AppTextStyles.displayLarge),
                    TextButton(
                      onPressed: _launchStoreWebsite,
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffD4A437),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              StoreCategoryGrid(onCardTap: _launchStoreWebsite),
              const SizedBox(height: 24),

              // --- Bestsellers Section ---
              //const SectionHeader(title: 'Bestsellers'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bestsellers', style: AppTextStyles.displayLarge),
                    TextButton(
                      onPressed: _launchStoreWebsite,
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffD4A437),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              StoreBestsellersGrid(onCardTap: _launchStoreWebsite),
              const SizedBox(height: 24),

              StoreFooterButton(onTap: _launchStoreWebsite),
              const SizedBox(
                height: 120,
              ), // Buffer cushion so navigation doesn't block the footer text
            ],
          ),
        ),
      ),
    );
  }
}
