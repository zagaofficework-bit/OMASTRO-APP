import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omastro/features/auth/bloc/auth_bloc.dart';
import 'package:omastro/features/auth/bloc/auth_event.dart';
import 'package:omastro/features/auth/bloc/auth_state.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Exact color hex definitions matching the UI mockup layout precisely
    const primaryGold = Color(0xFFE5C693);
    const softCreamBg = Color(0xFFFFFBF2);

    return BlocListener<AuthBloc, AuthState>(
      bloc: globalAuthBloc,
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is PhoneOtpSentState) {
          _showOtpDialog(context, state.verificationId);
        }
      },
      child: Scaffold(
      backgroundColor: softCreamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60.0),

                // --- 1. App Logo Asset Holder ---
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png', // Uses your custom OMR logo asset
                      height: 50,
                      width: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // --- 2. Typography Header Block ---
                const Text(
                  'SACRED JOURNEY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(text: 'Welcome to '),
                      TextSpan(
                        text: 'Om Astro',
                        style: TextStyle(color: Color(0xFFD4AF37)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Sign in to consult with verified astrologers.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 40.0),

                // --- 3. White Input Card Core Container ---
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Phone Number TextField Field
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Phone, e.g. +919876543210',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: Colors.black54,
                            size: 20,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFFEFEFEF),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: primaryGold,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Send SMS Code Button Action Block
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            String phone = _phoneController.text.trim();
                            if (phone.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a phone number')),
                              );
                              return;
                            }
                            if (!phone.startsWith('+')) {
                              phone = '+91$phone'; // Default to Indian country code
                            }
                            globalAuthBloc.add(SendPhoneOtpRequested(phone));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGold,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Send SMS code',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // Disclaimer Text block
                      const Text(
                        'Standard SMS rates may apply. Include your country code (e.g. +91 for India).',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Custom "OR" Divider block
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color(0xFFEFEFEF),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFFEFEFEF),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Google Authentication Button Option
                      SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () {
                            // 2. Change state natively!
                            globalAuthBloc.add(GoogleSignInRequested());

                            // NOTE: You do NOT write context.go('/home') here!
                            // The refreshListenable detects the state change, fires the
                            // redirect guard rule, and smoothly slides the home screen into view.
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFEFEFEF),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/google.svg',
                                height: 20,
                                width: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32.0),

                // --- 4. Bottom Legal Footer Block ---
                const Text(
                  'By continuing you agree to our Terms and Privacy Policy.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  void _showOtpDialog(BuildContext context, String verificationId) {
    final TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              hintText: '6-digit code',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final otp = otpController.text.trim();
                if (otp.length == 6) {
                  Navigator.pop(context);
                  globalAuthBloc.add(VerifyPhoneOtpRequested(verificationId, otp));
                }
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }
}
