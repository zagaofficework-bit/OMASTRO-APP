import 'package:flutter/material.dart';

class ProfileStatsCard extends StatelessWidget {
  final String rating;
  final String minsCount;

  const ProfileStatsCard({
    super.key,
    this.rating = "5.0",
    this.minsCount = "0",
  });

  @override
  Widget build(BuildContext context) {
    const double containerHeight = 84.0;
    const dividerColor = Color(0xFFE5DCC3);

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
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
          // --- 1. Rating Stat Item ---
          Expanded(child: _buildStatItem('⭐ $rating', "Rating")),

          // Vertical Divider
          Container(height: 40, width: 1, color: dividerColor),

          // --- 2. Mins Stat Item ---
          Expanded(child: _buildStatItem('$minsCount mins', "Consulted")),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
