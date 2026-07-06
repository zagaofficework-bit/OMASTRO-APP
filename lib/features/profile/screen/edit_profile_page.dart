import 'package:flutter/material.dart';
import 'package:omastro/features/profile/widgets/edit_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/edit_avatar_picker.dart';
import '../widgets/info_group_card.dart';
import '../widgets/gender_choice_chips.dart';
import '../widgets/primary_submit_button.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // 1. Text Controllers tracking form state changes
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _dobController;
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    // Pre-filling with user session parameters matching our core dashboard context
    _nameController = TextEditingController(text: 'Satvik Dev');
    _emailController = TextEditingController(text: 'satvik.it.dev@gmail.com');
    _dobController = TextEditingController(text: '15-08-2002');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  /// Launches native themed DatePicker flow to eliminate manual text inputs
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2002, 8, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  AppColors.primary, // Selection accent matching design colors
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formats picked parameters elegantly back into the form display layer
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0), // Premium cream tone base tint
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profile Photo Media Upload Component Node
              const SizedBox(height: AppSpacing.sm),
              EditAvatarPicker(
                name: _nameController.text,
                onTap: () {
                  // TODO: Trigger bottom sheet layout choices for image source picker context
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Core Profile Form Card Block
              InfoGroupCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Text(
                    'Personal Information',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Editable Name Parameter Field
                  EditTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Protected Read-Only Identity Parameter Field
                  EditTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    prefixIcon: Icons.mail_outline,
                    readOnly: true,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Interactive Date Context Field Hook
                  EditTextField(
                    controller: _dobController,
                    label: 'Date of Birth',
                    prefixIcon: Icons.cake_outlined,
                    readOnly:
                        true, // Forces touch interaction directly to the DatePicker modal
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Gender Choice Chips Sub-selection Node
                  GenderChoiceChips(
                    selectedGender: _selectedGender,
                    onGenderSelected: (gender) {
                      setState(() => _selectedGender = gender);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 3. Persistent Core Submit Actions Button
              PrimarySubmitButton(
                label: 'Save Changes',
                onPressed: () {
                  // TODO: Push mutated form details data contexts back to your remote data blocks
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              const SizedBox(height: AppSpacing.xl),
              const SizedBox(
                height: AppSpacing.xl,
              ), // Extra spacing to ensure bottom navigation bar doesn't overlap content
            ],
          ),
        ),
      ),
    );
  }
}
