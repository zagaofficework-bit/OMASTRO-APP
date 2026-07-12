import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
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
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../astrologers/bloc/astrologers_bloc.dart';
import '../../astrologers/bloc/astrologers_state.dart';


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

                      // Who I Follow Section
                      BlocBuilder<AstrologersBloc, AstrologersState>(
                        builder: (context, state) {
                          List<String> followedNames = [];
                          if (state is AstrologersFollowingState) {
                            followedNames = state.followedAstrologers;
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite_rounded,
                                      color: Color(0xffE4A834),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Who I Follow',
                                      style: AppTextStyles.displayMedium
                                          .copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 7),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1.0,
                                  ),
                                ),
                                child: followedNames.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12.0,
                                          ),
                                          child: Text(
                                            'Follow your favorite astrologers to see them here!',
                                            textAlign: TextAlign.center,
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color: Colors.grey[500],
                                                  fontSize: 12,
                                                ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        height: responsive.scale(
                                          90,
                                          min: 82,
                                          max: 104,
                                        ),
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: followedNames.length,
                                          itemBuilder: (context, index) {
                                            final name = followedNames[index];
                                            // Look up full astrologer details
                                            final details = (state is AstrologersFollowingState) 
                                                ? state.astrologers.firstWhere(
                                                    (element) => element['name'] == name,
                                                    orElse: () => <String, dynamic>{},
                                                  )
                                                : <String, dynamic>{};

                                            if (details.isEmpty) {
                                              return const SizedBox.shrink();
                                            }

                                            final String img = details['avatar_url'] ?? '';
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 16.0,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  // Construct the Map<String, String> that AstrologerProfilePage expects
                                                  context.push(
                                                    '/astrologer-profile',
                                                    extra: {
                                                      'name':
                                                          details['name']
                                                              ?.toString() ??
                                                          '',
                                                      'imageUrl':
                                                          details['image']
                                                              ?.toString() ??
                                                          '',
                                                      'specialties':
                                                          (details['specialties']
                                                                  as List?)
                                                              ?.join(', ') ??
                                                          '',
                                                      'languages':
                                                          (details['languages']
                                                                  as List?)
                                                              ?.join(', ') ??
                                                          '',
                                                      'experience':
                                                          '${details['experience']} Years',
                                                      'rate':
                                                          details['price']
                                                              ?.toString() ??
                                                          '0',
                                                      'bio':
                                                          details['bio']
                                                              ?.toString() ??
                                                          '',
                                                    },
                                                  );
                                                },
                                                child: Column(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: responsive.scale(
                                                        26,
                                                        min: 23,
                                                        max: 30,
                                                      ),
                                                      backgroundColor:
                                                          AppColors.background,
                                                      backgroundImage:
                                                          img.startsWith(
                                                            'assets/',
                                                          )
                                                          ? AssetImage(img)
                                                                as ImageProvider
                                                          : NetworkImage(img),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      name
                                                          .split(' ')
                                                          .last, // Show short name or last part
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .textPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              ),
                              SizedBox(
                                height: responsive.scale(
                                  AppSpacing.sm,
                                  min: 8,
                                  max: 14,
                                ),
                              ),
                            ],
                          );
                        },
                      ),



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
