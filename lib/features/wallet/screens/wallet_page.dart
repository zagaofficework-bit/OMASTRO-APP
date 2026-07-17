import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/balance_banner.dart';
import '../widgets/custom_amount_input.dart';
import '../widgets/recharge_grid.dart';
import '../widgets/recent_transactions_block.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int _selectedAmount = 500;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _selectedAmount.toString());
    context.read<WalletBloc>().add(LoadWallet());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handlePresetSelected(int amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toString();
    });
  }

  void _handleCustomAmountChanged(String val) {
    setState(() {
      _selectedAmount = int.tryParse(val) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDF9), Color(0xFFF7F2E9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Top Bar with Back Button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.scale(16),
                  vertical: responsive.scale(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        shadowColor: Colors.black.withOpacity(0.04),
                        elevation: 4,
                      ),
                    ),
                    SizedBox(width: responsive.scale(16)),
                    Text(
                      'Wallet Balance',
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: responsive.font(20, min: 18, max: 24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
              child: SingleChildScrollView(
          padding: responsive.pagePadding(vertical: AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: responsive.pageConstraints(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: responsive.scale(12, min: 8, max: 18)),
                  BlocBuilder<WalletBloc, WalletState>(
                    builder: (context, state) {
                      double balance = 0.0;
                      if (state is WalletBalanceUpdated) {
                        balance = state.balance;
                      }
                      return BalanceBanner(
                        balance: balance,
                      );
                    },
                  ),
                  SizedBox(
                    height: responsive.scale(AppSpacing.lg, min: 18, max: 28),
                  ),
                  Text(
                    'Quick recharge',
                    style: AppTextStyles.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: responsive.scale(12, min: 10, max: 16)),
                  RechargeGrid(
                    selectedAmount: _selectedAmount,
                    onAmountSelected: _handlePresetSelected,
                  ),
                  SizedBox(height: responsive.scale(12, min: 10, max: 16)),
                  CustomAmountInput(
                    controller: _amountController,
                    onChanged: _handleCustomAmountChanged,
                  ),
                  SizedBox(height: responsive.scale(16, min: 12, max: 20)),
                  SizedBox(
                    width: double.infinity,
                    height: responsive.scale(50, min: 46, max: 56),
                    child: ElevatedButton(
                      onPressed: _selectedAmount > 0
                          ? () {
                              context.read<WalletBloc>().add(
                                AddMoney(_selectedAmount.toDouble()),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Rs $_selectedAmount added to your wallet!',
                                  ),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Text(
                        '+ Add Rs $_selectedAmount',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: Colors.white,
                          fontSize: responsive.font(16, min: 14, max: 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: responsive.scale(8, min: 6, max: 10)),
                  Center(
                    child: Text(
                      'Secure payments via Cashfree',
                      style: TextStyle(
                        fontSize: responsive.font(11, min: 10, max: 12),
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: responsive.scale(AppSpacing.xl, min: 24, max: 36),
                  ),
                  const RecentTransactionsBlock(),
                  SizedBox(height: responsive.bottomInset),
                ],
              ),
            ),
          ),
        ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
