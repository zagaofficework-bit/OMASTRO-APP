import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ValueNotifier<bool> splashCompletedNotifier = ValueNotifier<bool>(false);

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Always start at false on entry so splash is guaranteed to display for 2 full seconds
    splashCompletedNotifier.value = false;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.15, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    // Exact 2.0 second duration so the user sees the splash screen clearly
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        splashCompletedNotifier.value = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final splashWidth = (screenWidth * 0.85).clamp(280.0, 440.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/images/splash_cropped.png',
                    width: splashWidth,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xffD4A437),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
