import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  // Call this method when user taps "Continue with Google" or signs in via SMS
  void signInUser() {
    _isLoggedIn = true;
    notifyListeners(); // 👈 Crucial: Triggers GoRouter to instantly re-evaluate paths!
  }

  // Call this when the user logs out from profile settings
  void signOutUser() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

// Global instance to use across routing layers
final globalAuthProvider = AuthProvider();
