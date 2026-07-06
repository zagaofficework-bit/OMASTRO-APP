import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class GenderChoiceChips extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderSelected;

  const GenderChoiceChips({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> genders = ['Male', 'Female', 'Other'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: genders.map((gender) {
            final isSelected = selectedGender == gender;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(gender),
                selected: isSelected,
                onSelected: (val) {
                  if (val) onGenderSelected(gender);
                },
                selectedColor: AppColors.primary,
                labelStyle: isSelected
                    ? AppTextStyles.bodyMedium.copyWith(color: Colors.white)
                    : AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
