import 'dart:math' as math;

import 'package:flutter/material.dart';

enum AppDeviceType { mobile, tablet, desktop }

class ResponsiveProvider extends InheritedWidget {
  final ResponsiveData data;

  const ResponsiveProvider({
    super.key,
    required this.data,
    required super.child,
  });

  static ResponsiveData of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ResponsiveProvider>();

    return provider?.data ?? ResponsiveData.fromContext(context);
  }

  @override
  bool updateShouldNotify(ResponsiveProvider oldWidget) {
    return data != oldWidget.data;
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget child;

  const ResponsiveBuilder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final data = ResponsiveData.fromContext(context);

    return ResponsiveProvider(
      data: data,
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(data.textScale)),
        child: child,
      ),
    );
  }
}

class ResponsiveData {
  final Size size;
  final EdgeInsets viewPadding;
  final Orientation orientation;
  final double textScale;

  const ResponsiveData({
    required this.size,
    required this.viewPadding,
    required this.orientation,
    required this.textScale,
  });

  factory ResponsiveData.fromContext(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final width = mediaQuery.size.width;

    final baseScale = width / 390;

    return ResponsiveData(
      size: mediaQuery.size,
      viewPadding: mediaQuery.padding,
      orientation: mediaQuery.orientation,
      textScale: baseScale.clamp(0.92, 1.08).toDouble(),
    );
  }

  //---------------------------------------
  // Screen Info
  //---------------------------------------

  double get width => size.width;

  double get height => size.height;

  bool get isMobile => width < 600;

  bool get isTablet => width >= 600 && width < 1024;

  bool get isDesktop => width >= 1024;

  AppDeviceType get deviceType {
    if (isDesktop) return AppDeviceType.desktop;
    if (isTablet) return AppDeviceType.tablet;
    return AppDeviceType.mobile;
  }

  //---------------------------------------
  // Common Layout
  //---------------------------------------

  double get horizontalPadding {
    if (isDesktop) return 40;
    if (isTablet) return 28;
    return width < 360 ? 12 : 16;
  }

  EdgeInsets pagePadding({double vertical = 16}) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: vertical,
    );
  }

  BoxConstraints pageConstraints() {
    return BoxConstraints(maxWidth: pageMaxWidth);
  }

  double get pageMaxWidth {
    if (isDesktop) return 980;
    if (isTablet) return 760;
    return double.infinity;
  }

  //---------------------------------------
  // App Shell
  //---------------------------------------

  double get topBarContentHeight => isMobile ? 64 : 72;

  double get topBarHeight => topBarContentHeight + viewPadding.top;

  double get bottomNavHeight => isMobile ? 72 : 80;

  double get bottomInset => bottomNavHeight + viewPadding.bottom + 24;

  double get heroTopGap => topBarHeight + (isMobile ? 12 : 20);

  //---------------------------------------
  // Grid Counts
  //---------------------------------------

  int get categoryColumns {
    if (isDesktop) return 6;
    if (isTablet) return 4;
    return 3;
  }

  int get storeColumns {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 2;
  }

  //---------------------------------------
  // Featured Astrologer Card
  //---------------------------------------

  double get featuredCardWidth {
    if (isDesktop) return 210;
    if (isTablet) return 190;

    return math.max(150, math.min(170, width * 0.42));
  }

  double get featuredCardHeight {
    if (isDesktop) return 250;
    if (isTablet) return 225;

    return 205;
  }

  //---------------------------------------
  // Banner
  //---------------------------------------

  double get bannerHeight {
    if (isDesktop) return 220;
    if (isTablet) return 180;
    return 140;
  }

  //---------------------------------------
  // Scaling Helpers
  //---------------------------------------

  double scale(double value, {double min = 0, double? max}) {
    final scaled = value * (width / 390).clamp(0.90, 1.20);

    return scaled.clamp(min, max ?? double.infinity);
  }

  double font(double value, {double min = 10, double? max}) {
    final scaled = value * textScale;

    return scaled.clamp(min, max ?? value + 3);
  }

  //---------------------------------------

  @override
  bool operator ==(Object other) {
    return other is ResponsiveData &&
        other.size == size &&
        other.viewPadding == viewPadding &&
        other.orientation == orientation &&
        other.textScale == textScale;
  }

  @override
  int get hashCode {
    return Object.hash(size, viewPadding, orientation, textScale);
  }
}

extension ResponsiveContext on BuildContext {
  ResponsiveData get responsive => ResponsiveProvider.of(this);
}
