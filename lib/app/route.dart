import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/core/auth/auth_provider.dart';
import 'package:omastro/features/astrologers/screen/astrologer_category_page.dart';
import 'package:omastro/features/astrologers/screen/astrologers_profile.dart';
import 'package:omastro/features/auth/screen/sign_in_page.dart';
import 'package:omastro/features/call/screens/live_call_page.dart';
// 🌟 1. FIXED IMPORT PATH
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
  refreshListenable: globalAuthProvider,
  redirect: (context, state) {
    final bool loggedIn = globalAuthProvider.isLoggedIn;
    final bool goingToLogin = state.matchedLocation == '/login';

    if (!loggedIn && !goingToLogin) {
      return '/login';
    }

    if (loggedIn && goingToLogin) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/live-call',
      builder: (context, state) {
        final astrologerData = state.extra as Map<String, dynamic>;
        return LiveCallPage(astrologer: astrologerData);
      },
    ),
    GoRoute(path: '/login', builder: (context, state) => const SignInPage()),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomePage()),
        GoRoute(path: '/estore', builder: (_, _) => const EStorePage()),

        GoRoute(
          path: '/astrologers',
          builder: (_, _) => const AstrologerCategoryPage(),
        ),

        GoRoute(
          path: '/hub-list',
          builder: (_, _) => const AstrologerPage(initialCategory: 'All'),
        ),

        GoRoute(
          path: '/hub-list/:category',
          builder: (context, state) {
            final category = state.pathParameters['category'] ?? 'All';
            return AstrologerPage(initialCategory: category);
          },
        ),

        GoRoute(
          path: '/astrologer-profile',
          builder: (context, state) {
            final astrologerData = state.extra as Map<String, String>;
            return AstrologerProfilePage(astrologerData: astrologerData);
          },
        ),

        // 🌟 2. ADDED THE LIVE-CALL ROUTE ENTRY HERE
        GoRoute(path: '/live', builder: (_, _) => const LivePage()),
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
        GoRoute(path: '/wallet', builder: (_, _) => const WalletPage()),
      ],
    ),
  ],
);
