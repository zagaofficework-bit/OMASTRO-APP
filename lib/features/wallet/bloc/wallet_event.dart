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
  final String? astrologerId;
  final String? astrologerName;
  const DeductMoney(this.amount, {this.astrologerId, this.astrologerName});

  @override
  List<Object> get props => [
    amount,
    if (astrologerId != null) astrologerId!,
    if (astrologerName != null) astrologerName!,
  ];
}

class DeductForChat extends WalletEvent {
  final double amount;
  final String astrologerId;
  const DeductForChat({required this.amount, required this.astrologerId});

  @override
  List<Object> get props => [amount, astrologerId];
}
