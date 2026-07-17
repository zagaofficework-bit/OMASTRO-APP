import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final _supabase = Supabase.instance.client;

  String? _walletUserId() => _supabase.auth.currentUser?.id;

  WalletBloc() : super(const WalletBalanceUpdated(0.00)) {
    on<LoadWallet>((event, emit) async {
      final walletUserId = _walletUserId();
      if (walletUserId == null) return;

      if (state is WalletBalanceUpdated) {
        emit(
          WalletBalanceUpdated(
            (state as WalletBalanceUpdated).balance,
            transactions: (state as WalletBalanceUpdated).transactions,
            isLoading: true,
          ),
        );
      }

      try {
        // Fetch wallet
        final walletRes = await _supabase
            .from('wallets')
            .select('balance_paise')
            .eq('user_id', walletUserId)
            .maybeSingle();

        const starterBalancePaise = 1500 * 100;
        double balance = 0.0;
        if (walletRes != null && walletRes['balance_paise'] != null) {
          final currentPaise = walletRes['balance_paise'] as int;
          balance = currentPaise / 100.0;
        } else {
          // Create wallet if it doesn't exist and seed it with ₹1500 ONE TIME.
          await _supabase.from('wallets').upsert({
            'user_id': walletUserId,
            'balance_paise': starterBalancePaise,
          }, onConflict: 'user_id');

          await _supabase.from('wallet_transactions').insert({
            'user_id': walletUserId,
            'amount_paise': starterBalancePaise,
            'kind': 'credit',
            'status': 'success',
            'note': 'Starter Wallet Bonus',
          });

          balance = 1500.0;
        }

        // Fetch transactions directly from Supabase wallet_transactions table
        final txRes = await _supabase
            .from('wallet_transactions')
            .select('id, user_id, amount_paise, kind, status, note, created_at')
            .eq('user_id', walletUserId)
            .order('created_at', ascending: false);

        final transactions = List<Map<String, dynamic>>.from(txRes);

        emit(
          WalletBalanceUpdated(
            balance,
            transactions: transactions,
            isLoading: false,
          ),
        );
      } catch (e) {
        print('Error loading wallet: $e');
        if (state is WalletBalanceUpdated) {
          emit(
            WalletBalanceUpdated(
              (state as WalletBalanceUpdated).balance,
              transactions: (state as WalletBalanceUpdated).transactions,
              isLoading: false,
            ),
          );
        }
      }
    });

    on<AddMoney>((event, emit) async {
      final walletUserId = _walletUserId();
      if (walletUserId == null) return;

      try {
        final amountPaise = (event.amount * 100).toInt();

        // 1. Insert transaction
        await _supabase.from('wallet_transactions').insert({
          'user_id': walletUserId,
          'amount_paise': amountPaise,
          'kind': 'credit',
          'status': 'success',
          'note': 'Deposit via App',
        });

        // 2. Fetch current balance safely
        final walletRes = await _supabase
            .from('wallets')
            .select('balance_paise')
            .eq('user_id', walletUserId)
            .maybeSingle();

        int currentPaise = 0;
        if (walletRes != null && walletRes['balance_paise'] != null) {
          currentPaise = walletRes['balance_paise'] as int;
        }

        final newPaise = currentPaise + amountPaise;

        // 3. Update or Insert balance
        await _supabase.from('wallets').upsert({
          'user_id': walletUserId,
          'balance_paise': newPaise,
        }, onConflict: 'user_id');

        add(LoadWallet()); // Refresh state
      } catch (e) {
        print('Error adding money: $e');
      }
    });

    on<DeductMoney>((event, emit) async {
      final walletUserId = _walletUserId();
      if (walletUserId == null) return;

      try {
        final amountPaise = (event.amount * 100).toInt();

        final walletRes = await _supabase
            .from('wallets')
            .select('balance_paise')
            .eq('user_id', walletUserId)
            .maybeSingle();

        int currentPaise = 0;
        if (walletRes != null && walletRes['balance_paise'] != null) {
          currentPaise = walletRes['balance_paise'] as int;
        }

        if (currentPaise >= amountPaise) {
          final newPaise = currentPaise - amountPaise;
          final double newBalance = newPaise / 100.0;

          await _supabase.from('wallet_transactions').insert({
            'user_id': walletUserId,
            'amount_paise': amountPaise,
            'kind': 'debit',
            'status': 'success',
            'note':
                'Call with ${event.astrologerName?.trim().isNotEmpty == true ? event.astrologerName : (event.astrologerId ?? 'Unknown')}',
          });

          await _supabase.from('wallets').upsert({
            'user_id': walletUserId,
            'balance_paise': newPaise,
          }, onConflict: 'user_id');

          emit(WalletDeductionSuccess(newBalance));
          add(LoadWallet()); // Refresh state
        } else {
          emit(
            WalletInsufficientBalance(
              currentBalance: currentPaise / 100.0,
              requiredAmount: event.amount,
            ),
          );
        }
      } catch (e) {
        print('Error deducting money: $e');
      }
    });

    on<DeductForChat>((event, emit) async {
      final walletUserId = _walletUserId();
      if (walletUserId == null) {
        emit(
          const WalletInsufficientBalance(currentBalance: 0, requiredAmount: 0),
        );
        return;
      }

      try {
        final amountPaise = (event.amount * 100).toInt();

        final walletRes = await _supabase
            .from('wallets')
            .select('balance_paise')
            .eq('user_id', walletUserId)
            .maybeSingle();

        int currentPaise = 0;
        if (walletRes != null && walletRes['balance_paise'] != null) {
          currentPaise = walletRes['balance_paise'] as int;
        }

        final double currentBalance = currentPaise / 100.0;

        if (currentPaise >= amountPaise) {
          final newPaise = currentPaise - amountPaise;
          final double newBalance = newPaise / 100.0;

          // 1. Generate unique consultation ID
          final String consultationId = 'chat_sess_${DateTime.now().millisecondsSinceEpoch}';

          // 2. Insert transaction
          final astroLabel = event.astrologerName?.trim().isNotEmpty == true ? event.astrologerName : event.astrologerId;
          await _supabase.from('wallet_transactions').insert({
            'user_id': walletUserId,
            'amount_paise': amountPaise,
            'kind': 'debit',
            'status': 'success',
            'note': 'Chat message with $astroLabel (ID: $consultationId)',
          });

          // 3. Insert consultation record
          await _supabase.from('consultations').insert({
            'id': consultationId,
            'user_id': walletUserId,
            'astrologer_id': event.astrologerId,
            'type': 'Chat',
            'status': 'Completed',
            'duration_seconds': 0,
            'started_at': DateTime.now().toIso8601String(),
            'ended_at': DateTime.now().toIso8601String(),
          });

          // Insert astrologer earnings with 0% platform commission
          await _supabase.from('astrologer_earnings').insert({
            'astrologer_id': event.astrologerId,
            'consultation_id': consultationId,
            'gross_amount': event.amount,
            'commission_rate': 0.00,
            'net_amount': event.amount,
            'status': 'UNPAID',
          });

          // 4. Update wallet
          await _supabase.from('wallets').upsert({
            'user_id': walletUserId,
            'balance_paise': newPaise,
          }, onConflict: 'user_id');

          emit(WalletDeductionSuccess(newBalance));
          add(LoadWallet()); // Refresh state
        } else {
          emit(
            WalletInsufficientBalance(
              currentBalance: currentBalance,
              requiredAmount: event.amount,
            ),
          );
        }
      } catch (e) {
        print('Error in DeductForChat: $e');
        emit(
          const WalletInsufficientBalance(currentBalance: 0, requiredAmount: 0),
        );
      }
    });
  }
}
