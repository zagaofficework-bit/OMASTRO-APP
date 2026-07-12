import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:omastro/features/auth/bloc/auth_bloc.dart';
import 'package:omastro/features/auth/bloc/auth_event.dart';
import '../widgets/info_group_card.dart';
import '../widgets/profile_menu_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;
  bool _emailUpdates = false;

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Sign Out',
            style: AppTextStyles.headingMedium,
          ),
          content: Text(
            'Do you really want to sign out?',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                if (context.canPop()) {
                  context.pop(); // Back to profile
                }
                globalAuthBloc.add(SignOutRequested()); // Trigger auth logout routing redirect
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Sign Out',
                style: AppTextStyles.buttonText.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAccountSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Account Security', style: AppTextStyles.headingMedium),
        content: Text('This feature is coming soon!', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: AppTextStyles.buttonText.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Account', style: AppTextStyles.headingMedium),
        content: Text('Are you sure you want to delete your account? This action cannot be undone.', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.buttonText.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requested.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete', style: AppTextStyles.buttonText.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Settings',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Notifications
              Text(
                'Notifications',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 12),
              InfoGroupCard(
                padding: EdgeInsets.zero,
                children: [
                  SwitchListTile(
                    activeThumbColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    title: Text('Push Notifications', style: AppTextStyles.headingSmall),
                    subtitle: Text('Get live calls and alerts', style: AppTextStyles.bodySecondary),
                    value: _pushNotifications,
                    onChanged: (val) {
                      setState(() {
                        _pushNotifications = val;
                      });
                    },
                  ),
                  Divider(color: AppColors.border.withValues(alpha: 0.5), height: 1),
                  SwitchListTile(
                    activeThumbColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    title: Text('Email Updates', style: AppTextStyles.headingSmall),
                    subtitle: Text('Receive newsletter and offers', style: AppTextStyles.bodySecondary),
                    value: _emailUpdates,
                    onChanged: (val) {
                      setState(() {
                        _emailUpdates = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section 2: Account Management
              Text(
                'Account',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 12),
              InfoGroupCard(
                padding: EdgeInsets.zero,
                children: [

                  ProfileMenuTile(
                    icon: Icons.security_rounded,
                    title: 'Account Security',
                    subtitle: 'Manage passwords and verification',
                    onTap: () => _showAccountSecurityDialog(context),
                  ),
                  ProfileMenuTile(
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete Account',
                    subtitle: 'Permanently remove your account data',
                    iconColor: AppColors.error,
                    isLast: true,
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Sign Out Option
              InfoGroupCard(
                padding: EdgeInsets.zero,
                children: [
                  ProfileMenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out Account',
                    subtitle: 'Safely logout of this device',
                    iconColor: AppColors.error,
                    isLast: true,
                    onTap: () => _showSignOutDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
