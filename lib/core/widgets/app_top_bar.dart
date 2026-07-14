import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import 'package:omastro/features/chat/screens/chat_page.dart';
import 'package:omastro/features/wallet/bloc/wallet_bloc.dart';
import 'package:omastro/features/wallet/bloc/wallet_state.dart';
import 'package:omastro/features/chat/bloc/chat_bloc.dart';
import 'package:omastro/features/chat/bloc/chat_state.dart';

import '../theme/app_colors.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
    final statusBarHeight = responsive.viewPadding.top;
    final logoSize = responsive.scale(42, min: 36, max: 48);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: responsive.topBarHeight,
          padding: EdgeInsets.fromLTRB(
            responsive.horizontalPadding,
            statusBarHeight,
            responsive.horizontalPadding,
            0,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.70),
            border: const Border(
              bottom: BorderSide(color: Color(0x25D4A437), width: 1.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        color: const Color(0xffF8F2E8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xffE4A834).withValues(alpha: 0.2),
                        ),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: responsive.scale(10, min: 8, max: 12)),
                    Flexible(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: responsive.font(20, min: 18, max: 22),
                            fontWeight: FontWeight.w600,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Om ',
                              style: TextStyle(
                                fontFamily: 'serif',
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: 'Astro',
                              style: TextStyle(
                                fontFamily: 'serif',
                                color: Color(0xffD4A437),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: responsive.scale(8, min: 6, max: 14)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      int unreadCount = 0;
                      if (state is ChatUpdatedState) {
                        unreadCount = state.totalUnreadCount;
                      }
                      
                      return Badge(
                        isLabelVisible: unreadCount > 0,
                        label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
                        backgroundColor: AppColors.error,
                        offset: const Offset(4, -4),
                        child: _CircleIconButton(
                          icon: Icons.chat_bubble_outline,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ChatsPage(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(width: responsive.scale(10, min: 8, max: 12)),
                  BlocBuilder<WalletBloc, WalletState>(
                    builder: (context, state) {
                      double balance = 0.0;
                      if (state is WalletBalanceUpdated) {
                        balance = state.balance;
                      }
                      
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: responsive.scale(112, min: 88, max: 128),
                        ),
                        child: OutlinedButton(
                          onPressed: () => context.push('/wallet'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(
                              responsive.scale(72, min: 62, max: 86),
                              responsive.scale(38, min: 34, max: 42),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.scale(12, min: 8, max: 14),
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            side: const BorderSide(color: Color(0x40D4A437)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Text(
                            'Rs ${balance.toStringAsFixed(2)}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.textPrimary,
                              fontSize: responsive.font(13, min: 11, max: 14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
    final size = responsive.scale(40, min: 36, max: 44);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x40D4A437)),
          ),
          child: Icon(
            icon,
            size: responsive.scale(20, min: 18, max: 22),
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
