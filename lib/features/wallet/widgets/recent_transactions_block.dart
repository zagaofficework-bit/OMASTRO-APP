import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_state.dart';

class RecentTransactionsBlock extends StatelessWidget {
  const RecentTransactionsBlock({super.key});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent transactions',
          style: AppTextStyles.headingMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            List<Map<String, dynamic>> transactions = [];
            if (state is WalletBalanceUpdated) {
              transactions = state.transactions;
            }

            if (transactions.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.lg,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF9E6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Color(0xFFD4A373),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No transactions yet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your activity will appear here.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show top 5 recent transactions
            final displayCount = transactions.length > 5 ? 5 : transactions.length;
            final recentTxs = transactions.take(displayCount).toList();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: recentTxs.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final tx = recentTxs[index];
                  final isCredit = tx['kind'] == 'credit';
                  final amountPaise = tx['amount_paise'] as num? ?? 0;
                  final amount = amountPaise / 100.0;
                  
                  final dateStr = tx['created_at'] as String?;
                  DateTime? date;
                  if (dateStr != null) {
                    date = DateTime.tryParse(dateStr)?.toLocal();
                  }
                  
                  final dateFormatted = date != null 
                      ? DateFormat('dd MMM yyyy, hh:mm a').format(date)
                      : 'Unknown Date';

                  final rawNote = tx['note'] as String? ?? (isCredit ? 'Deposit' : 'Payment');
                  final noteFormatted = _formatTransactionNote(rawNote);

                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCredit ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: isCredit ? Colors.green : Colors.red,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              noteFormatted,
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateFormatted,
                              style: AppTextStyles.bodySecondary.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: isCredit ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
