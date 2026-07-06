import 'package:flutter/material.dart';

class LiveAvatarGlowFrame extends StatelessWidget {
  final String imageUrl;

  const LiveAvatarGlowFrame({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(
          0xFFE5A65E,
        ).withValues(alpha: 0.08), // Outer ambient ring
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(
            0xFFE5A65E,
          ).withValues(alpha: 0.15), // Inner ambient ring
        ),
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(
                0xFFE5A65E,
              ).withValues(alpha: 0.6), // Sharp gold border rim
              width: 2,
            ),
            image: imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageUrl.isEmpty
              ? const Icon(Icons.person, size: 60, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
