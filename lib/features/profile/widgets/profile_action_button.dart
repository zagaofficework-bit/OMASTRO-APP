import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color foregroundColor;
  final Color backgroundColor;
  final BorderSide? borderSide;
  final double paddingHorizontal;
  final double paddingVertical;

  const ProfileActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.foregroundColor,
    this.backgroundColor = Colors.white,
    this.borderSide,
    this.paddingHorizontal = 14.0,
    this.paddingVertical = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: foregroundColor),
      label: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        side: borderSide ?? const BorderSide(color: Color(0xFFF4EFEA)),
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
