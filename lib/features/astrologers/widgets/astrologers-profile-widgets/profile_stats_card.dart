import 'package:flutter/material.dart';

class ProfileStatsCard extends StatelessWidget {
  final String ordersCount;
  final String followersCount;
  final String minsCount;

  const ProfileStatsCard({
    super.key,
    this.ordersCount = "500",
    this.followersCount = "2.5k+",
    this.minsCount = "3k+",
  });

  @override
  Widget build(BuildContext context) {
    // Soft cream tint matching the background layer of the screenshot precisely
    const double containerHeight = 84.0;
    const dividerColor = Color(0xFFE5DCC3);

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          40,
        ), // Creates the elegant pill capsule curve
        border: Border.all(
          color: dividerColor.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // --- 1. Orders Stat Item ---
          Expanded(child: _buildStatItem(ordersCount, "orders")),

          // Vertical Divider
          Container(height: 40, width: 1, color: dividerColor),

          // --- 2. Followers Stat Item ---
          Expanded(child: _buildStatItem(followersCount, "followers")),

          // Vertical Divider
          Container(height: 40, width: 1, color: dividerColor),

          // --- 3. Mins Stat Item ---
          Expanded(child: _buildStatItem(minsCount, "mins")),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
