import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/info_group_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';

class MyDetailsPage extends StatelessWidget {
  const MyDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String name = '';
        String email = '';
        String dob = '';
        String gender = '';
        String phone = '';
        String avatarUrl = '';

        if (state is ProfileLoaded) {
          name = state.name;
          email = state.email;
          dob = state.dob;
          gender = state.gender;
          phone = state.phone;
          avatarUrl = state.avatarUrl ?? '';
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/profile');
                  }
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  shape: const CircleBorder(),
                ),
              ),
            ),
            title: Text(
              'My Account',
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 28),
                onPressed: () {
                  context.push('/edit-profile');
                },
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  // Avatar Frame
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: avatarUrl.isNotEmpty 
                          ? Colors.transparent 
                          : AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: avatarUrl.isNotEmpty 
                          ? NetworkImage(avatarUrl) 
                          : null,
                      child: avatarUrl.isEmpty 
                          ? Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  InfoGroupCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      _buildDetailRow('Full Name', name, Icons.person_outline),
                      const Divider(),
                      _buildDetailRow('Email Address', email, Icons.mail_outline),
                      const Divider(),
                      _buildDetailRow('Date of Birth', dob, Icons.cake_outlined),
                      const Divider(),
                      _buildDetailRow('Gender', gender, Icons.wc_outlined),
                      const Divider(),
                      _buildDetailRow('Phone Number', phone, Icons.phone_android_outlined),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  ElevatedButton(
                    onPressed: () {
                      context.push('/edit-profile');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Edit Profile',
                      style: AppTextStyles.buttonText.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
