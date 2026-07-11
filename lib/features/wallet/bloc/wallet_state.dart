import 'package:equatable/equatable.dart';

abstract class WalletState extends Equatable {
  const WalletState();
  
  @override
  List<Object> get props => [];
}

class WalletBalanceUpdated extends WalletState {
  final double balance;

  const WalletBalanceUpdated(this.balance);

  @override
  List<Object> get props => [balance];
}

