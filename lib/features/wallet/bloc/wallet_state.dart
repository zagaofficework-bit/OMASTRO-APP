import 'package:equatable/equatable.dart';

abstract class WalletState extends Equatable {
  const WalletState();
  
  @override
  List<Object> get props => [];
}

class WalletBalanceUpdated extends WalletState {
  final double balance;
  final List<Map<String, dynamic>> transactions;
  final bool isLoading;

  const WalletBalanceUpdated(
    this.balance, {
    this.transactions = const [],
    this.isLoading = false,
  });

  @override
  List<Object> get props => [balance, transactions, isLoading];
}

class WalletDeductionSuccess extends WalletState {
  final double newBalance;
  const WalletDeductionSuccess(this.newBalance);

  @override
  List<Object> get props => [newBalance];
}

class WalletInsufficientBalance extends WalletState {
  final double currentBalance;
  final double requiredAmount;
  const WalletInsufficientBalance({required this.currentBalance, required this.requiredAmount});

  @override
  List<Object> get props => [currentBalance, requiredAmount];
}
