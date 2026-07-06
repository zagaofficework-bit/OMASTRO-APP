import 'package:flutter/material.dart';

class LiveCallDisconnectButton extends StatelessWidget {
  final VoidCallback onTap;

  const LiveCallDisconnectButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFF3B30), // Crisp system hang-up red
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF3B30),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.call_end, color: Colors.white, size: 28),
      ),
    );
  }
}
