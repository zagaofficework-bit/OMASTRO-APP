import 'package:flutter/material.dart';

class LiveCallBackground extends StatelessWidget {
  final Widget child;

  const LiveCallBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2E1654), // Deep cosmic purple top
            Color(0xFF140727), // Midnight violet mid
            Color(0xFF080214), // Absolute dark space base
          ],
        ),
      ),
      child: child,
    );
  }
}
