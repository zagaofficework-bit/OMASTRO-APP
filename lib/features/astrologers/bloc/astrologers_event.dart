import 'package:equatable/equatable.dart';

abstract class AstrologersEvent extends Equatable {
  const AstrologersEvent();

  @override
  List<Object> get props => [];
}

class LoadAstrologers extends AstrologersEvent {}
