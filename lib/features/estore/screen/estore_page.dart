import 'package:flutter/material.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
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
    final responsive = ResponsiveProvider.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: responsive.pageConstraints(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 66),

                  const StoreHeader(),
                  SizedBox(height: responsive.scale(16, min: 12, max: 20)),

                  const StoreFeaturesRow(),
                  SizedBox(height: responsive.scale(24, min: 18, max: 30)),

                  // --- Category Section ---
                  // const SectionHeader(title: 'Shop by category'),
                  Padding(
                    padding: EdgeInsets.all(responsive.horizontalPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shop by category',
                          style: AppTextStyles.displayLarge,
                        ),
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
                  SizedBox(height: responsive.scale(24, min: 18, max: 30)),

                  // --- Bestsellers Section ---
                  //const SectionHeader(title: 'Bestsellers'),
                  Padding(
                    padding: EdgeInsets.all(responsive.horizontalPadding),
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
                  SizedBox(height: responsive.scale(24, min: 18, max: 30)),

                  StoreFooterButton(onTap: _launchStoreWebsite),
                  SizedBox(height: responsive.bottomInset),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
