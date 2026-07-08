import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 500.00;

  double get balance => _balance;

  void addMoney(double amount) {
    _balance += amount;
    notifyListeners();
  }

  void deductMoney(double amount) {
    if (_balance >= amount) {
      _balance -= amount;
      notifyListeners();
    }
  }
}

final globalWalletProvider = WalletProvider();
