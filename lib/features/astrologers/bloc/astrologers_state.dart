import 'package:equatable/equatable.dart';

abstract class AstrologersState extends Equatable {
  const AstrologersState();
  
  @override
  List<Object> get props => [];
}

class AstrologersFollowingState extends AstrologersState {
  final List<String> followedAstrologers;
  final List<Map<String, dynamic>> astrologers;
  final bool isLoading;

  const AstrologersFollowingState({
    this.followedAstrologers = const [],
    this.astrologers = const [],
    this.isLoading = false,
  });

  @override
  List<Object> get props => [followedAstrologers, astrologers, isLoading];
}

