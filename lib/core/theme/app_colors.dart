import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // --- Primary Branding & Accents ---
  // The signature warm mustard gold / saffron tone used for active navigation tabs,
  // major call-to-action buttons, headers, and main brand highlights.
  // Reference screens: home_Page.jpg, Astrologers_profile_page.jpg, Profile_page.jpg
  static const Color primary = Color(0xFFD49E35);
  static const Color primaryLight = Color(0xFFE5BE6B);
  static const Color primaryDark = Color(0xFF9E701C);

  // Star rating indicators and specialized premium highlights.
  // Reference screens: home_Page.jpg, astrologers_search page.jpg
  static const Color accentGold = Color(0xFFFFB300);

  // --- Background & Surface Canvases ---
  // The distinct soft cream background tint applied globally across light mode screens.
  // Reference screens: home_Page.jpg, Astrologers_categories page.jpg, E-store page.jpg
  static const Color background = Color(0xFFFAF6EE);

  // Solid crisp white utilized exclusively for component cards, search fields, and container backgrounds.
  // Reference screens: home_Page.jpg, Astrologers_categories page.jpg
  static const Color surface = Color(0xFFFFFFFF);

  // --- Dark Immersive Communication Environments ---
  // The deep dark navy/indigo canvas reserved for active call overlays and streaming states.
  // Reference screens: video_call page.png, Calling Page.jpg
  static const Color darkBackground = Color(0xFF1E2130);
  static const Color darkSurface = Color(0xFF2B2F44);

  // --- Typography Scale ---
  // Near-black slate for premium title headers, active options, and high-readability text.
  static const Color textPrimary = Color(0xFF1F1F2C);

  // Muted steel gray for descriptions, tags, subtitles, and secondary card information.
  static const Color textSecondary = Color.fromRGBO(111, 114, 133, 1);

  // Light tint for text field placeholders or disabled meta labels.
  static const Color textLight = Color(0xFFA5A9BC);

  // --- Functional UI & Status Indicators ---
  // Vibrant emerald green used to display live, active presence dots next to astrologers.
  // Reference screens: home_Page.jpg, Astrologers_profile_page.jpg
  static const Color onlineGreen = Color(0xFF2EC4B6);

  // Intense pulsing red chip signifying a broadcast is actively live.
  // Reference screens: Live astrologers page.jpg, video_call page.png
  static const Color liveRed = Color(0xFFFF3366);

  // Destructive call hanging or termination red button.
  // Reference screens: Calling Page.jpg, video_call page.png
  static const Color error = Color(0xFFE63946);

  // Faint divider line color used to cleanly border cards, fields, and tables without visual clutter.
  // Reference screens: Chat — Om Astro-chat page.png, Profile_page.jpg
  static const Color border = Color(0xFFEAECEF);
  // --- Add Your Master Gold Gradient ---
  static const Gradient goldGradient = LinearGradient(
    colors: [
      Color(0xffE4A834), // Rich golden saffron
      Color(0xffAD7A18), // Deep warm bronze
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient blackGradient = LinearGradient(
    colors: [
      Color.fromARGB(111, 114, 133, 1), // Rich golden saffron
      Color.fromARGB(111, 114, 133, 1), // Deep warm bronze
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
