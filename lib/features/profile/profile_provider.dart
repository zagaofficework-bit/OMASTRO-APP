import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = 'Satvik Dev';
  final String _email = 'satvik.it.dev@gmail.com';
  String _dob = '15 May 1995';
  String _gender = 'Male';
  final String _phone = '+91 9876543210';

  String get name => _name;
  String get email => _email;
  String get dob => _dob;
  String get gender => _gender;
  String get phone => _phone;

  void updateProfile({
    required String name,
    required String dob,
    required String gender,
  }) {
    _name = name;
    _dob = dob;
    _gender = gender;
    notifyListeners();
  }
}

final globalProfileProvider = ProfileProvider();
