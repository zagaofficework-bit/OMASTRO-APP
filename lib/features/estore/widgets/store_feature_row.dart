import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StoreFeaturesRow extends StatelessWidget {
  const StoreFeaturesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          _FeatureCard(
            icon: Icons.verified_outlined,
            label: 'Energized & certified',
          ),
          const SizedBox(width: 10),
          _FeatureCard(
            icon: Icons.local_shipping_outlined,
            label: 'India-wide shipping',
          ),
          const SizedBox(width: 10),
          _FeatureCard(
            icon: Icons.auto_awesome_outlined,
            label: 'Handcrafted',
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureCard({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.0), // Clean rounded corners matching the image
        border: Border.all(
          color: const Color(0xffEFEAE2),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xffD4A437), // Elegant golden icon tint
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.0,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}