import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._(); // Private constructor to prevent instantiation

  // --- Corner Curvature Tokens ---
  // Sharp, minimal rounding used for internal details or minor highlights.
  // Reference screens: E-store page.jpg (Small mini labels/badges)
  static const double sm = 4.0;

  // Medium rounding configuration matching standard structural component containers.
  // Reference screens: home_Page.jpg, E-store page.jpg (Astrologer cards and product display grids)
  static const double md = 12.0;

  // Pronounced smooth curvature used for larger layered dialog components and main blocks.
  // Reference screens: Astrologers_categories page.jpg (Category grid display boxes)
  static const double lg = 20.0;

  // High curvature applied exclusively to inputs, search modules, and distinct layout blocks.
  // Reference screens: astrologers_search page.jpg, Chat — Om Astro-chat page.png (Main search fields & chat bubble layout)
  static const double xl = 28.0;

  // Full capsule configuration matching round action switches and buttons perfectly.
  // Reference screens: Profile_page.jpg ("Save changes"), home_Page.jpg (Floating bottom nav bar outline layout)
  static const double round = 99.0;

  // --- Pre-built BorderRadius Objects ---
  static final BorderRadius radiusSm = BorderRadius.circular(sm);
  static final BorderRadius radiusMd = BorderRadius.circular(md);
  static final BorderRadius radiusLg = BorderRadius.circular(lg);
  static final BorderRadius radiusXl = BorderRadius.circular(xl);
  static final BorderRadius radiusRound = BorderRadius.circular(round);
}
