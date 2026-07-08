import 'package:flutter/material.dart';

class ProfileAvatarFrame extends StatelessWidget {
  final String imageUrl;
  final bool isOnline;
  final double radius;

  const ProfileAvatarFrame({
    super.key,
    required this.imageUrl,
    this.isOnline = true,
    this.radius =
        54.0, // Perfectly balances out to a total diameter of 108px matching the layout
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // --- 1. OUTER ACCENT CONTAINER BORDER RING ---
          Container(
            padding: const EdgeInsets.all(
              4.0,
            ), // Outer ring breathing buffer gap space
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(
                  0xffE4A834,
                ), // Matches the golden brand theme
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: const Color(0xffFDF8F2),
              // --- 2. PROFILE IMAGE HOST VIEWPORT ---
              child: ClipOval(
                child: imageUrl.startsWith('assets/')
                    ? Image.asset(
                        imageUrl,
                        width: radius * 2,
                        height: radius * 2,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        imageUrl,
                        width: radius * 2,
                        height: radius * 2,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person_rounded,
                          size: radius,
                          color: const Color(0xffD4931A),
                        ),
                      ),
              ),
            ),
          ),

          // --- 3. FLOATING STATUS DOT INDICATOR ---
          if (isOnline)
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xff10B981), // Solid active green dot
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white, // Crisp separation ring buffer
                    width: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
