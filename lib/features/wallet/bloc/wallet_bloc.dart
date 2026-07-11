import 'package:flutter_bloc/flutter_bloc.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(const WalletBalanceUpdated(500.00)) {
    on<AddMoney>((event, emit) {
      final currentState = state;
      if (currentState is WalletBalanceUpdated) {
        emit(WalletBalanceUpdated(currentState.balance + event.amount));
      }
    });

    on<DeductMoney>((event, emit) {
      final currentState = state;
      if (currentState is WalletBalanceUpdated) {
        if (currentState.balance >= event.amount) {
          emit(WalletBalanceUpdated(currentState.balance - event.amount));
        }
      }
    });
  }
}

