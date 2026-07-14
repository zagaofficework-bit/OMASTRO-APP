import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/features/auth/bloc/auth_bloc.dart';
import 'package:omastro/features/auth/bloc/auth_state.dart';
import 'package:omastro/core/bloc/go_router_refresh_stream.dart';
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
import '../features/profile/screen/settings_page.dart';
import '../features/wallet/screen/transaction_history_page.dart';
import '../features/profile/screen/consultation_history_page.dart';
import '../features/profile/screen/support_page.dart';
import '../features/chat/screens/chat_room_page.dart';
import '../features/call/screens/video_call_page.dart';
import '../features/profile/screen/edit_profile_page.dart';
import '../features/profile/screen/my_details_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/home',
  refreshListenable: GoRouterRefreshStream(globalAuthBloc.stream),
  redirect: (context, state) {
    final bool loggedIn = globalAuthBloc.state is Authenticated;
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
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const HomePage()),
        GoRoute(path: '/estore', builder: (_, _) => const EStorePage()),

        GoRoute(
          path: '/astrologers',
          builder: (_, _) => const AstrologerPage(initialCategory: 'All'),
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


        GoRoute(path: '/live', builder: (_, _) => const LivePage()),
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
      ],
    ),
    GoRoute(path: '/wallet', builder: (_, _) => const WalletPage()),
  ],
);
