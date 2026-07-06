import 'package:flutter/material.dart';
import 'package:omastro/features/profile/screen/edit_profile_page.dart';
import 'package:omastro/features/profile/widgets/verfication_badge_phone.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../widgets/profile_action_button.dart';
import '../widgets/dynamic_greeting_header.dart';
import '../widgets/info_group_card.dart';
import '../widgets/profile_info_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock user email context (Simulating initial registration state)
    const String userEmail = 'satvik.it.dev@gmail.com';
    bool isPhoneVerified = false;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0), // Cream tone base background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 54.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Context Navigation Action Layer (Edit Profile Button)
                Align(
                  alignment: Alignment.topRight,
                  child: ProfileActionButton(
                    label: 'Edit Profile',
                    icon: Icons.edit_outlined,
                    foregroundColor: AppColors.primary,
                    onPressed: () {
                      // TODO: Navigate to the standalone Edit Profile page route here
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // 2. Pure Visual Profile Banner Identity Layer
                const DynamicGreetingHeader(email: userEmail),
                const SizedBox(height: AppSpacing.md),

                // 3. Primary Biographical Info Card Block
                InfoGroupCard(
                  children: [
                    // Full name displays dynamically extracted string until explicitly overwritten
                    ProfileInfoTile(
                      icon: Icons.person_outline,
                      label: 'Full Name',
                      value:
                          'Satvik Dev', // This matches the dynamic email output string context
                    ),
                    ProfileInfoTile(
                      icon: Icons.mail_outline,
                      label: 'Email Address',
                      value: userEmail,
                    ),
                    ProfileInfoTile(
                      icon: Icons.cake_outlined,
                      label: 'Date of Birth',
                      value: '15 August 2002',
                    ),
                    ProfileInfoTile(
                      icon: Icons.wc_outlined,
                      label: 'Gender',
                      value: 'Male',
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // 4. Secondary Security Detail Block
                InfoGroupCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 4,
                  ),
                  children: [
                    ProfileInfoTile(
                      icon: Icons.smartphone_outlined,
                      label: 'Phone Number',
                      value: '+91 9812345678',
                      isLast: true,
                      trailing: VerificationBadge(
                        isVerified: isPhoneVerified,
                        onTap: () {
                          // Direct user right into the edit screen flow if unverified
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // 5. Clean Lifecycle Execution Trigger (Sign Out Button)
                Center(
                  child: ProfileActionButton(
                    label: 'Sign Out Account',
                    icon: Icons.logout_rounded,
                    foregroundColor: Colors.redAccent,
                    borderSide: BorderSide(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                    ),
                    paddingHorizontal: 24,
                    paddingVertical: 12,
                    onPressed: () {
                      // TODO: Insert auth session tear-down handlers here
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const SizedBox(height: AppSpacing.xl),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
