import 'package:equatable/equatable.dart';

abstract class AstrologersState extends Equatable {
  const AstrologersState();
  
  @override
  List<Object> get props => [];
}

class AstrologersFollowingState extends AstrologersState {
  final List<String> followedAstrologers;

  const AstrologersFollowingState({this.followedAstrologers = const []});

  @override
  List<Object> get props => [followedAstrologers];
}

