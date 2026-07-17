import 'dart:async';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/astrologer_dashboard/bloc/astrologer_dashboard_bloc.dart';
import '../../features/astrologer_dashboard/bloc/astrologer_dashboard_event.dart';
import '../../features/astrologer_dashboard/bloc/astrologer_dashboard_state.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/chat/bloc/chat_bloc.dart';
import '../../features/chat/bloc/chat_state.dart';
import '../theme/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';

class AstrologerShell extends StatefulWidget {
  final Widget child;

  const AstrologerShell({super.key, required this.child});

  @override
  State<AstrologerShell> createState() => _AstrologerShellState();
}

class _AstrologerShellState extends State<AstrologerShell> {
  late final StreamSubscription _connectivitySubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then((result) {
      _updateConnectionStatus(result);
    });

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });

    final authState = globalAuthBloc.state;
    if (authState is AuthenticatedAsAstrologer) {
      context.read<AstrologerDashboardBloc>().add(LoadAstrologerDashboard(
        astrologerId: authState.astrologerId,
        firebaseUid: authState.firebaseUid,
      ));
    }
  }

  void _updateConnectionStatus(dynamic result) {
    List<ConnectivityResult> results = [];
    if (result is List) {
      results = List<ConnectivityResult>.from(result);
    } else if (result is ConnectivityResult) {
      results = [result];
    }
    
    final isOffline = results.isEmpty || results.contains(ConnectivityResult.none);
    if (_isOffline != isOffline) {
      setState(() {
        _isOffline = isOffline;
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Widget _buildOfflineBanner() {
    return Container(
      color: const Color(0xFFFFF1F0),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.wifi, color: Colors.redAccent, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'No Internet Connection. Mobile data or Wi-Fi is required.',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    int calculateIndex() {
      if (location == '/astrologer-home') return 0;
      if (location == '/astrologer-chats') return 1;
      if (location == '/astrologer-history') return 2;
      if (location == '/astrologer-profile-page') return 3;
      return 0;
    }

    final currentIndex = calculateIndex();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: false,
      body: Column(
        children: [
          if (_isOffline) _buildOfflineBanner(),
          // Top bar with online toggle
          _buildAstrologerTopBar(context),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: _buildAstrologerBottomNavigation(context, currentIndex),
      ),
    );
  }

  Widget _buildAstrologerBottomNavigation(BuildContext context, int currentIndex) {
    final responsive = ResponsiveProvider.of(context);
    final barHeight = responsive.bottomNavHeight;
    final horizontalMargin = responsive.isDesktop
        ? 40.0
        : responsive.isTablet
        ? 28.0
        : 16.0;

    final items = [
      {'icon': FontAwesomeIcons.borderAll, 'label': 'Dashboard', 'route': '/astrologer-home'},
      {'icon': FontAwesomeIcons.solidComment, 'label': 'Chats', 'route': '/astrologer-chats'},
      {'icon': FontAwesomeIcons.clockRotateLeft, 'label': 'History', 'route': '/astrologer-history'},
      {'icon': FontAwesomeIcons.solidUser, 'label': 'Profile', 'route': '/astrologer-profile-page'},
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 8),
      height: barHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
          child: Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Material(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: items.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final item = entry.value;
                  final bool isSelected = currentIndex == index;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          context.go(item['route'] as String);
                        },
                        borderRadius: BorderRadius.circular(30),
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFFE4A834), Color(0xFFD4A437)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFE4A834).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                item['icon'] as dynamic,
                                color: isSelected ? Colors.white : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 9,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAstrologerTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          BlocBuilder<AstrologerDashboardBloc, AstrologerDashboardState>(
            builder: (context, state) {
              final avatarUrl = state is AstrologerDashboardLoaded ? state.avatarUrl : null;
              
              if (avatarUrl != null && avatarUrl.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF6EC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                );
              }
              
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF6EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FaIcon(FontAwesomeIcons.solidUser, color: Color(0xFFD4AF37), size: 20),
              );
            },
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Astrologer Panel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Manage your consultations',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Online/Offline Toggle
          BlocBuilder<AstrologerDashboardBloc, AstrologerDashboardState>(
            builder: (context, state) {
              final isOnline = state is AstrologerDashboardLoaded ? state.isOnline : false;
              return GestureDetector(
                onTap: () {
                  context.read<AstrologerDashboardBloc>().add(ToggleOnlineStatus());
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOnline ? const Color(0xFF10B981) : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isOnline ? const Color(0xFF10B981) : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isOnline ? const Color(0xFF10B981) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              int unreadCount = 0;
              if (state is ChatUpdatedState) {
                unreadCount = state.totalUnreadCount;
              }
              
              return Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
                backgroundColor: AppColors.error,
                offset: const Offset(4, -4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
                    onPressed: () {
                      context.go('/astrologer-chats');
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
