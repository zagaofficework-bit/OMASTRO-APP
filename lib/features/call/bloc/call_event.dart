import 'package:equatable/equatable.dart';

abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object> get props => [];
}

class LoadCall extends CallEvent {}
