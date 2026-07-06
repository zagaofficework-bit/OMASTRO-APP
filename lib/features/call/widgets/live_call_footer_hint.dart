import 'package:flutter/material.dart';

class LiveCallFooterHint extends StatelessWidget {
  const LiveCallFooterHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tap end to leave the call',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 12,
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.center,
    );
  }
}
