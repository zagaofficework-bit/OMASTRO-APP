import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

class RechargeGrid extends StatelessWidget {
  final int selectedAmount;
  final ValueChanged<int> onAmountSelected;

  const RechargeGrid({
    super.key,
    required this.selectedAmount,
    required this.onAmountSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<int> presets = [100, 250, 500, 1000, 2000, 5000];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: presets.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio:
            2.2, // Matches the wider low-profile row proportions in the UI design image
      ),
      itemBuilder: (context, index) {
        final amount = presets[index];
        final isSelected = selectedAmount == amount;

        return GestureDetector(
          onTap: () => onAmountSelected(amount),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '₹$amount',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }
}
