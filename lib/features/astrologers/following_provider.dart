import 'package:flutter/material.dart';

class FollowingProvider extends ChangeNotifier {
  final Set<String> _followedAstrologers = {};

  List<String> get followedList => _followedAstrologers.toList();

  bool isFollowing(String name) {
    return _followedAstrologers.contains(name);
  }

  void toggleFollow(String name) {
    if (_followedAstrologers.contains(name)) {
      _followedAstrologers.remove(name);
    } else {
      _followedAstrologers.add(name);
    }
    notifyListeners();
  }
}

final globalFollowingProvider = FollowingProvider();
