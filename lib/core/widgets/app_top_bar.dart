import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:omastro/features/wallet/screens/wallet_page.dart';
import '../theme/app_colors.dart';
import '../../features/chat/screens/chat_page.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Top bar height + the device's system status bar padding
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double barHeight = 64.0 + statusBarHeight;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
        child: Container(
          height: barHeight,
          padding: EdgeInsets.fromLTRB(22, statusBarHeight, 22, 0),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.70),
            border: const Border(
              bottom: BorderSide(
                color: Color(0x25D4A437), // Subtle gold glass edge highlight
                width: 1.2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// LEFT SECTION
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xffF8F2E8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xffE4A834).withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                      // --- THIS EXTRACTS AND CLIPS THE IMAGE TO THE CIRCLE PERFECTLY ---
                      image: const DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit
                            .cover, // Forces the asset to scale and expand to cover the full circle area
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        // Default text color for the top bar
                      ),
                      children: [
                        TextSpan(
                          text: "Om ",
                          style: TextStyle(
                            fontFamily: 'serif',
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: "Astro",
                          style: TextStyle(
                            fontFamily: 'serif',
                            color: Color(0xffD4A437),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /// RIGHT SECTION
              Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.chat_bubble_outline,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ChatsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WalletPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(72, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      side: const BorderSide(color: Color(0x40D4A437)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      "₹ 0.00",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x40D4A437)),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
