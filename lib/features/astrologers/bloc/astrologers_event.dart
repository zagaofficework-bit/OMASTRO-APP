import 'package:equatable/equatable.dart';

abstract class AstrologersEvent extends Equatable {
  const AstrologersEvent();

  @override
  List<Object> get props => [];
}

class LoadAstrologers extends AstrologersEvent {}

class ToggleFollowAstrologer extends AstrologersEvent {
  final String name;

  const ToggleFollowAstrologer(this.name);

  @override
  List<Object> get props => [name];
}

