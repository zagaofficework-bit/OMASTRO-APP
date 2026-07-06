import 'package:flutter/material.dart';

class ConsultationActionDock extends StatelessWidget {
  final VoidCallback onChatTap;
  final VoidCallback onCallTap;
  final VoidCallback onVideoTap;

  const ConsultationActionDock({
    super.key,
    required this.onChatTap,
    required this.onCallTap,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // --- 1. CHAT CHANNELS ---
          Expanded(
            child: _buildActionButton(
              label: 'Chat',
              icon: Icons.chat_bubble_outline_rounded,
              color: const Color(0xff059669), // Crisp Emerald Green
              bgColor: const Color(0xffECFDF5),
              onTap: onChatTap,
            ),
          ),
          const SizedBox(width: 8),

          // --- 2. AUDIO CALL CHANNELS ---
          Expanded(
            child: _buildActionButton(
              label: 'Call',
              icon: Icons.call_outlined,
              color: const Color(0xff059669), // Matches chat action colors
              bgColor: const Color(0xffECFDF5),
              onTap: onCallTap,
            ),
          ),
          const SizedBox(width: 8),

          // --- 3. PREMIUM VIDEO CONSULTATION CHANNELS ---
          Expanded(
            child: _buildActionButton(
              label: 'Video',
              icon: Icons.videocam_outlined,
              color: const Color(0xffD97706), // Warm Amber
              bgColor: const Color(0xffFEF3C7),
              onTap: onVideoTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
