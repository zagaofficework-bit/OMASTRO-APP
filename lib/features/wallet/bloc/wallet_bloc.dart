import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final _supabase = Supabase.instance.client;

  WalletBloc() : super(const WalletBalanceUpdated(0.00)) {
    on<LoadWallet>((event, emit) async {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      if (state is WalletBalanceUpdated) {
        emit(WalletBalanceUpdated(
          (state as WalletBalanceUpdated).balance,
          transactions: (state as WalletBalanceUpdated).transactions,
          isLoading: true,
        ));
      }

      try {
        // Fetch wallet
        final walletRes = await _supabase
            .from('wallets')
            .select('balance_paise')
            .eq('user_id', user.id)
            .maybeSingle();
            
        double balance = 0.0;
        if (walletRes != null && walletRes['balance_paise'] != null) {
          balance = (walletRes['balance_paise'] as num) / 100.0;
        } else {
          // Create wallet if it doesn't exist
          await _supabase.from('wallets').insert({
            'user_id': user.id,
            'balance_paise': 0,
          });
        }

        // Fetch transactions
        final txRes = await _supabase
            .from('wallet_transactions')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);

        final transactions = List<Map<String, dynamic>>.from(txRes);

        emit(WalletBalanceUpdated(
          balance,
          transactions: transactions,
          isLoading: false,
        ));
      } catch (e) {
        print('Error loading wallet: $e');
        if (state is WalletBalanceUpdated) {
          emit(WalletBalanceUpdated(
            (state as WalletBalanceUpdated).balance,
            transactions: (state as WalletBalanceUpdated).transactions,
            isLoading: false,
          ));
        }
      }
    });

    on<AddMoney>((event, emit) async {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      try {
        final amountPaise = (event.amount * 100).toInt();

        // 1. Insert transaction
        await _supabase.from('wallet_transactions').insert({
          'user_id': user.id,
          'amount_paise': amountPaise,
          'kind': 'credit',
          'status': 'success',
          'note': 'Deposit via App',
        });

        // 2. Fetch current balance safely
        final walletRes = await _supabase
            .from('wallets')
            .select('balance_paise')
            .eq('user_id', user.id)
            .maybeSingle();

        int currentPaise = 0;
        if (walletRes != null && walletRes['balance_paise'] != null) {
          currentPaise = walletRes['balance_paise'] as int;
        }

        final newPaise = currentPaise + amountPaise;

        // 3. Update or Insert balance
        await _supabase
            .from('wallets')
            .upsert({
              'user_id': user.id,
              'balance_paise': newPaise,
            }, onConflict: 'user_id');

        add(LoadWallet()); // Refresh state
      } catch (e) {
        print('Error adding money: $e');
      }
    });

    on<DeductMoney>((event, emit) async {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      try {
        final amountPaise = (event.amount * 100).toInt();

        final walletRes = await _supabase
            .from('wallets')
            .select('balance_paise')
            .eq('user_id', user.id)
            .maybeSingle();

        int currentPaise = 0;
        if (walletRes != null && walletRes['balance_paise'] != null) {
          currentPaise = walletRes['balance_paise'] as int;
        }

        if (currentPaise >= amountPaise) {
          final newPaise = currentPaise - amountPaise;

          await _supabase.from('wallet_transactions').insert({
            'user_id': user.id,
            'amount_paise': amountPaise,
            'kind': 'debit',
            'status': 'success',
            'note': 'Service Deduction',
          });

          await _supabase
              .from('wallets')
              .upsert({
                'user_id': user.id,
                'balance_paise': newPaise,
              }, onConflict: 'user_id');

          add(LoadWallet()); // Refresh state
        }
      } catch (e) {
        print('Error deducting money: $e');
      }
    });
  }
}

