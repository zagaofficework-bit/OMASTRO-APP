// Inside lib/core/shell/main_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/app/navigation/navigation_items.dart';
import 'package:omastro/core/theme/app_colors.dart';
import 'package:omastro/core/widgets/app_top_bar.dart';
import 'package:omastro/core/widgets/bottom_navigation.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    int calculateIndex() {
      if (location == '/home') return 0;
      // 🚀 Check if the route is the categories page, the list page, OR the profile page!
      if (location.startsWith('/astrologer') ||
          location.startsWith('/hub-list')) {
        return 1; // Index of your Astrologers Bottom Navigation Tab icon slot
      }
      if (location == '/live') return 2;
      if (location == '/estore') return 3;
      if (location == '/profile') return 4;
      return 0;
    }

    final currentIndex = calculateIndex();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(child: child),
          const Positioned(top: 0, left: 0, right: 0, child: AppTopBar()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: AppBottomNavigation(
                currentIndex: currentIndex,
                onTap: (index) {
                  final selectedItem = navigationItems[index];
                  context.go(selectedItem.route);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
