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
  final _userFormKey = GlobalKey<FormState>();
  final _astroFormKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isAstrologerMode = false;
  bool _isSignUpMode = false;
  bool _obscurePassword = true;

  // Test accounts for quick reference
  static const _testAccounts = [
    {'name': 'Acharya Shivam', 'email': 'acharya.shivam@omastro.app'},
    {'name': 'Astro Priya', 'email': 'astro.priya@omastro.app'},
    {'name': 'Pandit Ramesh', 'email': 'pandit.ramesh@omastro.app'},
    {'name': 'Yogini Meera', 'email': 'yogini.meera@omastro.app'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

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
        // Navigation is handled by GoRouter redirect — no need to push here
      },
      child: Scaffold(
        backgroundColor: softCreamBg,
        body: BlocBuilder<AuthBloc, AuthState>(
          bloc: globalAuthBloc,
          builder: (context, state) {
            if (state is AuthLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xffF8F2E8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withAlpha(76),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const CircularProgressIndicator(color: Color(0xFFD4AF37)),
                    const SizedBox(height: 16),
                    const Text(
                      'Connecting...',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48.0),

                  // --- 1. App Logo Asset Holder ---
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: const Color(0xffF8F2E8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // --- 2. Typography Header Block ---
                  const Text(
                    'SACRED JOURNEY',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD4AF37),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      children: [
                        TextSpan(text: 'Welcome to \n'),
                        TextSpan(
                          text: 'Om Astro',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontFamily: 'PlayfairDisplay',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    _isAstrologerMode
                        ? 'Sign in as an Astrologer to manage your consultations.'
                        : 'Sign in to consult with verified astrologers.',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24.0),

                  // --- 3. USER / ASTROLOGER Toggle ---
                  _buildRoleToggle(primaryGold),
                  const SizedBox(height: 24.0),

                  // --- 4. Auth Form ---
                  _isAstrologerMode
                      ? _buildAstrologerForm(primaryGold)
                      : _buildUserForm(primaryGold),

                  const SizedBox(height: 32.0),

                  // --- 5. Bottom Legal Footer Block ---
                  const Text(
                    'By continuing you agree to our Terms and Privacy Policy.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        );
      },
    ),
  ),
);
  }

  // ── Role Toggle ──
  Widget _buildRoleToggle(Color primaryGold) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFEFEFEF), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _isAstrologerMode = false;
                _isSignUpMode = false;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isAstrologerMode ? primaryGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  "I'm a User",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: !_isAstrologerMode ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _isAstrologerMode = true;
                _isSignUpMode = false;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isAstrologerMode ? primaryGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: _isAstrologerMode ? Colors.black87 : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "I'm an Astrologer",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isAstrologerMode ? Colors.black87 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── User Form (existing phone + Google flow) ──
  Widget _buildUserForm(Color primaryGold) {
    return Container(
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
      child: Form(
        key: _userFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phone Number TextField Field
            TextFormField(
              controller: _phoneController,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a phone number';
                }
                return null;
              },
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
                borderSide: BorderSide(
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
                if (!_userFormKey.currentState!.validate()) return;
                String phone = _phoneController.text.trim();
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
    );
  }

  // ── Astrologer Form (email + password) ──
  Widget _buildAstrologerForm(Color primaryGold) {
    return Container(
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
      child: Form(
        key: _astroFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sign Up: Name field
            if (_isSignUpMode) ...[
              TextFormField(
                controller: _nameController,
                validator: (val) {
                  if (_isSignUpMode && (val == null || val.trim().isEmpty)) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              decoration: InputDecoration(
                hintText: 'Full Name',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.person_outline, color: Colors.black54, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFEFEFEF), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: primaryGold, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14.0),
          ],

          // Email field
          TextFormField(
            controller: _emailController,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter an email';
              }
              if (!val.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email (e.g. astro.priya@omastro.app)',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.mail_outline, color: Colors.black54, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFFEFEFEF), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: primaryGold, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14.0),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54, size: 20),
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFFEFEFEF), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: primaryGold, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20.0),

          // Sign In / Sign Up Button
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _submitAstrologerForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _isSignUpMode ? 'Create Account' : 'Sign In',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14.0),

          // Toggle Sign In / Sign Up
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isSignUpMode ? 'Already have an account? ' : 'New astrologer? ',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              GestureDetector(
                onTap: () => setState(() => _isSignUpMode = !_isSignUpMode),
                child: Text(
                  _isSignUpMode ? 'Sign In' : 'Sign Up',
                  style: TextStyle(
                    color: primaryGold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Test Accounts Hint Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEFEAE2), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Color(0xFFD4AF37)),
                    SizedBox(width: 6),
                    Text(
                      'Test Accounts',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ..._testAccounts.map((account) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _emailController.text = account['email']!;
                        _passwordController.text = 'Astro@2026';
                        _isSignUpMode = false;
                      });
                    },
                    child: Text(
                      '${account['name']} — ${account['email']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                )),
                const Text(
                  'Password: Astro@2026  (tap to autofill)',
                  style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _submitAstrologerForm() {
    if (!_astroFormKey.currentState!.validate()) return;
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isSignUpMode) {
      final name = _nameController.text.trim();
      globalAuthBloc.add(AstrologerSignUpRequested(name, email, password));
    } else {
      globalAuthBloc.add(AstrologerSignInRequested(email, password));
    }
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
