import 'package:flutter/material.dart';

class LiveCallerHeader extends StatelessWidget {
  final String name;

  const LiveCallerHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      textAlign: TextAlign.center,
    );
  }
}
