import 'package:flutter/material.dart';
import 'package:omastro/core/theme/app_colors.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
    final logoSize = responsive.scale(120, min: 100, max: 150);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                color: const Color(0xffF8F2E8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xffE4A834).withValues(alpha: 0.2),
                  width: 2,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: responsive.font(28, min: 24, max: 32),
                  fontWeight: FontWeight.w600,
                ),
                children: const [
                  TextSpan(
                    text: 'Om ',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: 'Astro',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Color(0xffD4A437),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
