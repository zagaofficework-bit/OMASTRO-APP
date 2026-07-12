import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

class LoadWallet extends WalletEvent {}

class AddMoney extends WalletEvent {
  final double amount;
  const AddMoney(this.amount);
  
  @override
  List<Object> get props => [amount];
}

class DeductMoney extends WalletEvent {
  final double amount;
  const DeductMoney(this.amount);
  
  @override
  List<Object> get props => [amount];
}

