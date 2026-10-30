import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static bool _hasSeen = false;

  /// Fast synchronous getter initialized during app boot
  static bool get hasSeenOnboarding => _hasSeen;

  /// Initialize preference cache at app start
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasSeen = prefs.getBool(_keyHasSeenOnboarding) ?? false;
    } catch (_) {
      _hasSeen = false;
    }
  }

  /// Mark onboarding flow as viewed and completed
  static Future<void> setOnboardingCompleted() async {
    _hasSeen = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasSeenOnboarding, true);
    } catch (_) {}
  }

  /// Reset onboarding state (useful for testing and profile re-tours)
  static Future<void> resetOnboarding() async {
    _hasSeen = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHasSeenOnboarding);
    } catch (_) {}
  }
}
