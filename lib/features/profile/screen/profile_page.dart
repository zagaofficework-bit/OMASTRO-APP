import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/dynamic_greeting_header.dart';
import '../widgets/info_group_card.dart';
import '../widgets/profile_menu_tile.dart';
import '../../wallet/bloc/wallet_bloc.dart';
import '../../wallet/bloc/wallet_state.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
    return Scaffold(
      backgroundColor: AppColors.background, // Cream tone base background
        body: SafeArea(
          child: SingleChildScrollView(
            padding: responsive.pagePadding(vertical: AppSpacing.sm),
            child: Center(
              child: ConstrainedBox(
                constraints: responsive.pageConstraints(),
                child: Padding(
                  padding: EdgeInsets.only(top: 66),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header with Edit Button
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          String name = '';
                          String email = '';
                              String avatarUrl = '';
                              if (state is ProfileLoaded) {
                                name = state.name;
                                email = state.email;
                                avatarUrl = state.avatarUrl ?? '';
                              }
                              return Stack(
                                children: [
                                  DynamicGreetingHeader(
                                    email: email,
                                    explicitName: name,
                                    avatarUrl: avatarUrl,
                                  ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () {
                                    context.push('/edit-profile');
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(
                        height: responsive.scale(
                          AppSpacing.xl,
                          min: 24,
                          max: 36,
                        ),
                      ),

                      // 2. Wallet Card (Listenable to WalletProvider)
                      BlocBuilder<WalletBloc, WalletState>(
                        builder: (context, state) {
                          double balance = 0.0;
                          if (state is WalletBalanceUpdated) {
                            balance = state.balance;
                          }
                          return Container(
                            padding: EdgeInsets.all(
                              responsive.scale(AppSpacing.md, min: 14, max: 20),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(
                                    responsive.scale(12, min: 10, max: 14),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(
                                  width: responsive.scale(
                                    AppSpacing.md,
                                    min: 12,
                                    max: 20,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Wallet Balance',
                                        style: AppTextStyles.bodySecondary,
                                      ),
                                      Text(
                                        '₹${balance.toStringAsFixed(2)}',
                                        style: AppTextStyles.headingMedium
                                            .copyWith(color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    context.push('/wallet');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text('Recharge'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: responsive.scale(10, min: 8, max: 14)),





                      // 3. App Features Menu List
                      InfoGroupCard(
                        padding: EdgeInsets.zero,
                        children: [
                          ProfileMenuTile(
                            icon: Icons.person_outline,
                            title: 'My Account',
                            subtitle: 'Personal details & preferences',
                            onTap: () {
                              context.push('/my-details');
                            },
                          ),
                          ProfileMenuTile(
                            icon: Icons.history_rounded,
                            title: 'Consultation History',
                            subtitle: 'Past calls & chats',
                            onTap: () {
                              context.push('/history');
                            },
                          ),
                          ProfileMenuTile(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Transaction History',
                            subtitle: 'Deposits & payments',
                            onTap: () {
                              context.push('/transaction-history');
                            },
                          ),
                          ProfileMenuTile(
                            icon: Icons.support_agent_rounded,
                            title: 'Help & Support',
                            subtitle: 'Contact us for any queries',
                            onTap: () {
                              context.push('/support');
                            },
                          ),
                          ProfileMenuTile(
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            subtitle: 'App preferences & notifications',
                            isLast: true,
                            onTap: () {
                              context.push('/settings');
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.bottomInset),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}
