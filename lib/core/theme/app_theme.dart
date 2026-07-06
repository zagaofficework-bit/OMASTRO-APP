import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_radius.dart';

class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      // --- Global Card Architecture ---
      // Reference screens: home_Page.jpg, E-store page.jpg
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        margin: EdgeInsets.zero,
      ),

      // --- Text Input Field Configurations ---
      // Reference screens: astrologers_search page.jpg, Chat — Om Astro-chat page.png
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppTextStyles.bodySecondary.copyWith(
          color: AppColors.textLight,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusXl,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusXl,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusXl,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),

      // --- Floating Bottom Navigation Bar ---
      // Reference screens: home_Page.jpg, Live astrologers page.jpg
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // --- Custom Typography Engine Mapping ---
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        headlineMedium: AppTextStyles.headingMedium,
        headlineSmall: AppTextStyles.headingSmall,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySecondary,
        labelSmall: AppTextStyles.caption,
      ),
    );
  }
}
