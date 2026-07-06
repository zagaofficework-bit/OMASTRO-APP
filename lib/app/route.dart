import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/core/auth/auth_provider.dart';
import 'package:omastro/features/astrologers/screen/astrologer_category_page.dart';
import 'package:omastro/features/astrologers/screen/astrologers_profile.dart'; // 👈 Export file containing your profile view class
import 'package:omastro/features/auth/screen/sign_in_page.dart';
import 'package:omastro/features/home/screen/home_page.dart';
import 'package:omastro/features/wallet/screens/wallet_page.dart';
import '../core/shell/main_shell.dart';
import '../features/estore/screen/estore_page.dart';
import '../features/live/screen/live_page.dart';
import '../features/profile/screen/profile_page.dart';
import '../features/astrologers/screen/astrologer_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  refreshListenable: globalAuthProvider, // 👈 Listens for auth state changes
  // 2. The Border Guard: Automatically checks logic rules on every state drop
  redirect: (context, state) {
    final bool loggedIn = globalAuthProvider.isLoggedIn;
    final bool goingToLogin = state.matchedLocation == '/login';

    // Rule A: If user is NOT logged in and trying to go inside app spaces -> Force to Login
    if (!loggedIn && !goingToLogin) {
      return '/login';
    }

    // Rule B: If user IS logged in but wandering around the login page -> Direct straight home
    if (loggedIn && goingToLogin) {
      return '/home';
    }

    // Otherwise, let them go where they intended naturally
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const SignInPage()),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomePage()),
        GoRoute(path: '/estore', builder: (_, _) => const EStorePage()),

        // --- 1. Bottom Nav Tab target: Lands on Categories Hub ---
        GoRoute(
          path: '/astrologers',
          builder: (_, _) => const AstrologerCategoryPage(),
        ),

        // --- 2. "See All" target: Completely distinct path ---
        GoRoute(
          path: '/hub-list',
          builder: (_, _) => const AstrologerPage(initialCategory: 'All'),
        ),

        // --- 3. Filtered target ---
        GoRoute(
          path: '/hub-list/:category',
          builder: (context, state) {
            final category = state.pathParameters['category'] ?? 'All';
            return AstrologerPage(initialCategory: category);
          },
        ),

        // --- 4. Dynamic Astrologer Profile Target ---
        GoRoute(
          path: '/astrologer-profile',
          builder: (context, state) {
            // 💡 Safely extract and explicitly type-cast the map dataset passed through 'extra'
            final astrologerData = state.extra as Map<String, String>;

            // Returns your profile widget populated with dynamic individual parameters
            return AstrologerProfilePage(astrologerData: astrologerData);
          },
        ),
        GoRoute(path: '/live', builder: (_, _) => const LivePage()),
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),

        GoRoute(path: '/wallet', builder: (_, _) => const WalletPage()),
      ],
    ),
  ],
);
