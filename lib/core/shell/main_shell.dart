import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/app/navigation/navigation_items.dart';
import 'package:omastro/core/theme/app_colors.dart';
import 'package:omastro/core/widgets/app_top_bar.dart';
import 'package:omastro/core/widgets/bottom_navigation.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
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
          Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 18),
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
      if (location == '/home') return 0;
      if (location.startsWith('/astrologer') ||
          location.startsWith('/hub-list')) {
        return 1;
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
          Positioned.fill(child: widget.child),
          const Positioned(top: 0, left: 0, right: 0, child: AppTopBar()),
          if (_isOffline)
            Positioned(
              top: MediaQuery.of(context).padding.top + 56, // Below top app bar
              left: 0,
              right: 0,
              child: _buildOfflineBanner(),
            ),
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
