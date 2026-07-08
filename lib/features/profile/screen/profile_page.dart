import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/dynamic_greeting_header.dart';
import '../widgets/info_group_card.dart';
import '../widgets/profile_menu_tile.dart';
import '../../wallet/wallet_provider.dart';
import '../profile_provider.dart';
import '../../astrologers/following_provider.dart';
import '../../astrologers/astrologers_data.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock user email context (Simulating initial registration state)
    const String userEmail = 'satvik.it.dev@gmail.com';
    return Scaffold(
      backgroundColor: AppColors.background, // Cream tone base background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header with Edit Button
                ListenableBuilder(
                  listenable: globalProfileProvider,
                  builder: (context, _) {
                    return Stack(
                      children: [
                        DynamicGreetingHeader(
                          email: userEmail,
                          explicitName: globalProfileProvider.name,
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
                const SizedBox(height: AppSpacing.xl),

                // 2. Wallet Card (Listenable to WalletProvider)
                ListenableBuilder(
                  listenable: globalWalletProvider,
                  builder: (context, _) {
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wallet Balance',
                                  style: AppTextStyles.bodySecondary,
                                ),
                                Text(
                                  '₹${globalWalletProvider.balance.toStringAsFixed(2)}',
                                  style: AppTextStyles.headingMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
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
                const SizedBox(height: 10),

                // Who I Follow Section
                ListenableBuilder(
                  listenable: globalFollowingProvider,
                  builder: (context, _) {
                    final followedNames = globalFollowingProvider.followedList;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
                                style: AppTextStyles.displayMedium.copyWith(
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
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: 90,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: followedNames.length,
                                    itemBuilder: (context, index) {
                                      final name = followedNames[index];
                                      // Look up full astrologer details
                                      final details = masterAstrologers
                                          .firstWhere(
                                            (element) =>
                                                element['name'] == name,
                                            orElse: () => <String, dynamic>{},
                                          );
                                      if (details.isEmpty)
                                        return const SizedBox.shrink();

                                      final String img = details['image'] ?? '';
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
                                                radius: 26,
                                                backgroundColor:
                                                    AppColors.background,
                                                backgroundImage:
                                                    img.startsWith('assets/')
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
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textPrimary,
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
                        const SizedBox(height: AppSpacing.sm),
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
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
