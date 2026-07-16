import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/features/auth/bloc/auth_bloc.dart';
import 'package:omastro/features/auth/bloc/auth_state.dart';
import 'package:omastro/core/bloc/go_router_refresh_stream.dart';
import 'package:omastro/features/astrologers/screen/astrologers_profile.dart';
import 'package:omastro/features/auth/screen/sign_in_page.dart';
import 'package:omastro/features/auth/screen/astrologer_onboarding_page.dart';
import 'package:omastro/features/call/screens/live_call_page.dart';
// 🌟 1. FIXED IMPORT PATH
import 'package:omastro/features/home/screen/home_page.dart';
import 'package:omastro/features/home/screen/splash_page.dart';
import 'package:omastro/features/wallet/screens/wallet_page.dart';
import '../core/shell/main_shell.dart';
import '../core/shell/astrologer_shell.dart';
import '../features/estore/screen/estore_page.dart';
import '../features/live/screen/live_page.dart';
import '../features/profile/screen/profile_page.dart';
import '../features/astrologers/screen/astrologer_page.dart';
import '../features/profile/screen/settings_page.dart';
import '../features/wallet/screen/transaction_history_page.dart';
import '../features/profile/screen/consultation_history_page.dart';
import '../features/profile/screen/support_page.dart';
import '../features/chat/screens/chat_room_page.dart';
import '../features/call/screens/video_call_page.dart';
import '../features/profile/screen/edit_profile_page.dart';
import '../features/profile/screen/my_details_page.dart';
import '../features/astrologer_dashboard/screens/astrologer_dashboard_page.dart';
import '../features/astrologer_dashboard/screens/astrologer_chat_history_page.dart';
import '../features/astrologer_dashboard/screens/astrologer_consultation_history_page.dart';
import '../features/astrologer_dashboard/screens/astrologer_profile_page.dart';
import '../features/astrologer_dashboard/screens/astrologer_edit_profile_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _astrologerShellKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: GoRouterRefreshStream(globalAuthBloc.stream),
  redirect: (context, state) {
    final authState = globalAuthBloc.state;
    final location = state.matchedLocation;

    final isChecking = authState is AuthInitial || authState is AuthLoading;
    if (isChecking) {
      if (location == '/splash') return null;
      return '/splash';
    }

    final isLoggedIn = authState is Authenticated ||
        authState is AuthenticatedAsAstrologer ||
        authState is AstrologerOnboardingRequired;

    final isAstrologer = authState is AuthenticatedAsAstrologer || authState is AstrologerOnboardingRequired;
    final needsOnboarding = authState is AstrologerOnboardingRequired;

    final isGoingToLogin = location == '/login';
    final isGoingToSplash = location == '/splash';
    final isGoingToOnboarding = location == '/astrologer-onboarding';
    final isAstrologerRoute = location.startsWith('/astrologer-');

    // Not logged in → force login
    if (!isLoggedIn && !isGoingToLogin) {
      return '/login';
    }

    // Logged in → don't show login page or splash page
    if (isLoggedIn && (isGoingToLogin || isGoingToSplash)) {
      if (needsOnboarding) return '/astrologer-onboarding';
      if (isAstrologer) return '/astrologer-home';
      return '/home';
    }

    // Astrologer needs onboarding → force onboarding
    if (needsOnboarding && !isGoingToOnboarding && !isGoingToLogin) {
      return '/astrologer-onboarding';
    }

    // Authenticated astrologer trying to access user pages → redirect to astrologer home
    if (isAstrologer && !isAstrologerRoute && !isGoingToLogin && location != '/chat-room' && location != '/live-call' && location != '/video-call') {
      return '/astrologer-home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/live-call',
      builder: (context, state) {
        final Map<String, dynamic> extraData = state.extra as Map<String, dynamic>? ?? {};
        final Map<String, dynamic> astrologerData = extraData['astrologer'] ?? extraData;
        final String? incomingCallId = extraData['incomingCallId'];
        return LiveCallPage(astrologer: astrologerData, incomingCallId: incomingCallId);
      },
    ),
    GoRoute(
      path: '/video-call',
      builder: (context, state) {
        final Map<String, dynamic> extraData = state.extra as Map<String, dynamic>? ?? {};
        final Map<String, dynamic> astrologerData = extraData['astrologer'] ?? extraData;
        final String? incomingCallId = extraData['incomingCallId'];
        return VideoCallPage(astrologer: astrologerData, incomingCallId: incomingCallId);
      },
    ),
    GoRoute(
      path: '/chat-room',
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>;
        return ChatRoomPage(
          id: params['id']!, 
          name: params['name']!,
          otherUid: params['otherUid'],
          avatarUrl: params['avatarUrl'],
        );
      },
    ),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
    GoRoute(
      path: '/transaction-history',
      builder: (context, state) => const TransactionHistoryPage(),
    ),
    GoRoute(path: '/edit-profile', builder: (context, state) => const EditProfilePage()),
    GoRoute(path: '/my-details', builder: (context, state) => const MyDetailsPage()),
    GoRoute(path: '/history', builder: (context, state) => const ConsultationHistoryPage()),
    GoRoute(path: '/support', builder: (context, state) => const SupportPage()),
    GoRoute(
      path: '/astrologer-profile',
      builder: (context, state) {
        final extra = state.extra as Map;
        final Map<String, String> astrologerData = {};
        for (final key in extra.keys) {
          astrologerData[key.toString()] = extra[key].toString();
        }
        return AstrologerProfilePage(astrologerData: astrologerData);
      },
    ),
    GoRoute(path: '/login', builder: (context, state) => const SignInPage()),
    GoRoute(path: '/astrologer-onboarding', builder: (context, state) => const AstrologerOnboardingPage()),

    // ── Astrologer Dashboard Shell ──
    ShellRoute(
      navigatorKey: _astrologerShellKey,
      builder: (context, state, child) {
        return AstrologerShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/astrologer-home',
          pageBuilder: (context, state) => const NoTransitionPage(child: AstrologerDashboardPage()),
        ),
        GoRoute(
          path: '/astrologer-chats',
          pageBuilder: (context, state) => const NoTransitionPage(child: AstrologerChatHistoryPage()),
        ),
        GoRoute(
          path: '/astrologer-history',
          pageBuilder: (context, state) => const NoTransitionPage(child: AstrologerConsultationHistoryPage()),
        ),
        GoRoute(
          path: '/astrologer-profile-page',
          pageBuilder: (context, state) => const NoTransitionPage(child: AstrologerDashboardProfilePage()),
        ),
        GoRoute(path: '/astrologer-edit-profile', builder: (context, state) => const AstrologerEditProfilePage()),
      ],
    ),

    // ── User Shell ──
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: '/estore',
          pageBuilder: (context, state) => const NoTransitionPage(child: EStorePage()),
        ),

        GoRoute(
          path: '/astrologers',
          pageBuilder: (context, state) => const NoTransitionPage(child: AstrologerPage(initialCategory: 'All')),
        ),

        GoRoute(
          path: '/hub-list',
          pageBuilder: (context, state) => const NoTransitionPage(child: AstrologerPage(initialCategory: 'All')),
        ),

        GoRoute(
          path: '/hub-list/:category',
          pageBuilder: (context, state) {
            final category = state.pathParameters['category'] ?? 'All';
            return NoTransitionPage(child: AstrologerPage(initialCategory: category));
          },
        ),


        GoRoute(
          path: '/live',
          pageBuilder: (context, state) => const NoTransitionPage(child: LivePage()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
        ),
      ],
    ),
    GoRoute(path: '/wallet', builder: (_, _) => const WalletPage()),
  ],
);
