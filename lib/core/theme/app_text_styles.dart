import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  // --- Display / Serif Styles ---
  // The iconic elegant serif typeface used for main app branding, page headers, and large headings.
  // Reference screens: home_Page.jpg ("Find your guide"), Astrologers_categories page.jpg ("Astrology Categories")
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'PlayfairDisplay', // Or your chosen elegant Serif font
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle mainStyle = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // secondary displayLarge style for main or big font
  static const TextStyle displayLarge02 = TextStyle(
    fontFamily: 'Serif font', // Or your chosen elegant Serif font
    fontSize: 40.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // --- Heading Styles ---
  // Used for prominent section headers on dashboards and profile screens.
  // Reference screens: Astrologers_profile_page.jpg ("User Reviews"), E-store page.jpg ("Shop by category", "Bestsellers")
  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'Poppins', // Clean contemporary sans-serif for UI clarity
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  // Used for primary titles inside cards, items, and dialogue boxes.
  // Reference screens: home_Page.jpg ("Yogini Meera"), E-store page.jpg ("Rudraksha Bracelets")
  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // --- Body Styles ---
  // Standard UI body text for primary data tags, forms, input labels, and chat contents.
  // Reference screens: Chat — Om Astro-chat page.png ("hi"), Profile_page.jpg ("Personal details")
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Muted supporting text for profile metadata descriptions, specializations, and subtitles.
  // Reference screens: astrologers_search page.jpg ("Tarot Reading • Numerology • 8+ yrs")
  static const TextStyle bodySecondary = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // --- Captions & Miniature Labels ---
  // Micro typography reserved for timestamps, small counter badges, and light disclaimer texts.
  // Reference screens: Chat — Om Astro-chat page.png ("11:05 PM"), Live astrologers page.jpg ("1,284 viewers")
  static const TextStyle caption = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  // Specialized highlighting typography configured strictly for pricing values or primary metrics.
  // Reference screens: Astrologers_profile_page.jpg ("₹25/min", "2.5k+ followers")
  static const TextStyle priceHighlight = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // --- Button Action Typography ---
  // High-contrast semi-bold font layout configurations targeted inside buttons.
  // Reference screens: Profile_page.jpg ("Save changes"), E-store page.jpg ("Browse the full store")
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: Color.fromARGB(250, 19, 19, 19),
    letterSpacing: 0.5,
  );
}
