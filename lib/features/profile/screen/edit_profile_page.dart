import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/features/profile/widgets/edit_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/edit_avatar_picker.dart';
import '../widgets/info_group_card.dart';
import '../widgets/gender_choice_chips.dart';
import '../widgets/primary_submit_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

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
    // Pre-filling with user session parameters from ProfileBloc
    final state = context.read<ProfileBloc>().state;
    String initialName = '';
    String initialEmail = '';
    String initialDob = '';
    String initialGender = 'Male';
    
    if (state is ProfileLoaded) {
      initialName = state.name;
      initialEmail = state.email;
      initialDob = state.dob;
      initialGender = state.gender;
    }

    _nameController = TextEditingController(text: initialName);
    _emailController = TextEditingController(text: initialEmail);
    _dobController = TextEditingController(text: initialDob);
    _selectedGender = initialGender;
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

  bool _hasChanges() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      return _nameController.text != state.name ||
          _dobController.text != state.dob ||
          _selectedGender != state.gender;
    }
    return false;
  }

  Future<int?> _showSaveOrDiscardDialog(BuildContext context) async {
    return await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Save changes?',
            style: AppTextStyles.headingMedium,
          ),
          content: Text(
            'You have unsaved changes. Do you really want to exit? Save changes first then exit, or discard them.',
            style: AppTextStyles.bodyMedium,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(0),
              child: Text(
                'Cancel',
                style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(2),
                  child: Text(
                    'Discard',
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save & Exit',
                    style: AppTextStyles.buttonText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleBack() async {
    if (_hasChanges()) {
      final choice = await _showSaveOrDiscardDialog(context);
      if (choice == 1) {
        _saveChanges();
        _performPop();
      } else if (choice == 2) {
        _performPop();
      }
    } else {
      _performPop();
    }
  }

  void _saveChanges() {
    context.read<ProfileBloc>().add(UpdateProfileEvent(
      name: _nameController.text,
      dob: _dobController.text,
      gender: _selectedGender,
    ));
  }

  void _performPop() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Premium cream tone base tint
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: _handleBack,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          _handleBack();
        },
        child: SafeArea(
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
                    style: AppTextStyles.headingMedium,
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
                  _saveChanges();
                  _performPop();
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
    ),
    );
  }
}
