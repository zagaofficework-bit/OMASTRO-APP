import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_state.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  String _formatTransactionNote(String note) {
    String cleaned = note;
    if (cleaned.contains(' (ID:')) {
      cleaned = cleaned.split(' (ID:').first;
    }
    
    final map = {
      'DRBaphzzYdYVcLnPfPAhYHynQn93': 'Astro Priya',
      '4QByl2hM3HZPj2cb0W4mYhXooMo2': 'Yogini Meera',
      'bD5luP4IfnbCU1s0EbRCjSGKWWf1': 'Pandit Ramesh',
      '7ddb004c-46ae-4714-87f3-81042c4a3e79': 'Pandit Ramesh',
      '28e48fff-bc76-43c3-b4fc-53e058bb2c6c': 'Yogini Meera',
      'astro-DRBaphzzYdYVcLnPfPAhYHynQn93': 'Astro Priya',
      'astro-4QByl2hM3HZPj2cb0W4mYhXooMo2': 'Yogini Meera',
      'astro-bD5luP4IfnbCU1s0EbRCjSGKWWf1': 'Pandit Ramesh',
      'astro-7ddb004c-46ae-4714-87f3-81042c4a3e79': 'Pandit Ramesh',
      'astro-28e48fff-bc76-43c3-b4fc-53e058bb2c6c': 'Yogini Meera',
    };

    for (final entry in map.entries) {
      if (cleaned.contains(entry.key)) {
        cleaned = cleaned.replaceAll(entry.key, entry.value);
      }
    }
    
    cleaned = cleaned.replaceAll('Chat message to Astro ID:', 'Chat with');
    cleaned = cleaned.replaceAll('Chat message with', 'Chat with');
    cleaned = cleaned.replaceAll('Call with Astro ID:', 'Call with');
    cleaned = cleaned.replaceAll('Call with Astrologer ID:', 'Call with');
    cleaned = cleaned.replaceAll('Consultation with Astrologer ID:', 'Call with');

    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: Text(
          'Transaction History',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            if (state is! WalletBalanceUpdated) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final transactions = state.transactions;

            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions yet.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final tx = transactions[index];

                final isCredit = tx['kind'] == 'credit';
                final amountPaise = tx['amount_paise'] as num? ?? 0;
                final amount = amountPaise / 100.0;

                final createdAt = tx['created_at'];
                DateTime? date;
                if (createdAt is DateTime) {
                  date = createdAt.toLocal();
                } else if (createdAt is String) {
                  date = DateTime.tryParse(createdAt)?.toLocal();
                }

                final dateFormatted = date != null
                    ? DateFormat('dd MMM yyyy, hh:mm a').format(date)
                    : 'Unknown Date';

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCredit
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCredit
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: isCredit ? Colors.green : Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatTransactionNote(tx['note'] ?? (isCredit ? 'Deposit' : 'Payment')),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormatted,
                            style: AppTextStyles.bodySecondary.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
