import 'package:flutter/material.dart';
import 'package:omastro/core/widgets/app_top_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/balance_banner.dart';
import '../widgets/recharge_grid.dart';
import '../widgets/custom_amount_input.dart';
import '../widgets/recent_transactions_block.dart';

import '../wallet_provider.dart';

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
    final parsed = int.tryParse(val) ?? 0;
    setState(() {
      _selectedAmount = parsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppTopBar(),
      ),
      backgroundColor: const Color(
        0xFFFAF6F0,
      ), // Matching cream background tone
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),

              // 1. Gold Available Balance Banner Box (Listenable to WalletProvider)
              ListenableBuilder(
                listenable: globalWalletProvider,
                builder: (context, _) {
                  return BalanceBanner(balance: globalWalletProvider.balance);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Preset Matrix Title & Grid List Selection Block
              Text(
                'Quick recharge',
                style: AppTextStyles.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              RechargeGrid(
                selectedAmount: _selectedAmount,
                onAmountSelected: _handlePresetSelected,
              ),
              const SizedBox(height: 12),

              // 3. Custom Manual Amount Text Box Field Input
              CustomAmountInput(
                controller: _amountController,
                onChanged: _handleCustomAmountChanged,
              ),
              const SizedBox(height: 16),

              // 4. Primary Interactive Dynamic Elevated Submission Action Block
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedAmount > 0
                      ? () {
                          globalWalletProvider.addMoney(_selectedAmount.toDouble());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('₹$_selectedAmount added to your wallet!'),
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
                    '+ Add ₹$_selectedAmount',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Payment Gateway Assurance Footer Caption
              Center(
                child: Text(
                  'Secure payments via Cashfree',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 5. Historical Empty State Transaction Log Frame Layout
              const RecentTransactionsBlock(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
