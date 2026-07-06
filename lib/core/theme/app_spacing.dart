import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // --- Layout Matrix Sizing ---
  // Micro padding configurations optimized for internal badge layouts, price items, and minor margins.
  // Reference screens: home_Page.jpg (Rating badge padding), Chat — Om Astro-chat page.png (Inside message bubbles)
  static const double xs = 4.0;

  // Compact layout spacing used between continuous rows, tiny text clusters, and micro elements.
  // Reference screens: astrologers_search page.jpg (Gap between action circles like chat/call icons)
  static const double sm = 8.0;

  // The global standard block gap configuration used for intermediate lists and element components.
  // Reference screens: Astrologers_categories page.jpg (Grid spacing between layout category squares)
  static const double md = 16.0;

  // Outer structural margin padding matching screen boundaries and separating large components.
  // Reference screens: home_Page.jpg, E-store page.jpg (Consistent outer side gutter padding layout)
  static const double lg = 24.0;

  // Wide layout blocks separating major visual structural modules.
  // Reference screens: Live astrologers page.jpg (Large margins separating individual stream cards)
  static const double xl = 32.0;

  // --- Pre-built Layout Spacers (SizedBoxes) ---
  static const SizedBox heightXxs = SizedBox(height: 5);
  static const SizedBox heightXs = SizedBox(height: xs);
  static const SizedBox heightSm = SizedBox(height: sm);
  static const SizedBox heightMd = SizedBox(height: md);
  static const SizedBox heightLg = SizedBox(height: lg);
  static const SizedBox heightXl = SizedBox(height: xl);

  static const SizedBox widthXs = SizedBox(width: xs);
  static const SizedBox widthSm = SizedBox(width: sm);
  static const SizedBox widthMd = SizedBox(width: md);
  static const SizedBox widthLg = SizedBox(width: lg);
  static const SizedBox widthXl = SizedBox(width: xl);
}
