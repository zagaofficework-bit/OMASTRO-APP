import 'package:equatable/equatable.dart';

abstract class CallState extends Equatable {
  const CallState();
  
  @override
  List<Object> get props => [];
}

class CallInitial extends CallState {}

class CallLoading extends CallState {}

class CallLoaded extends CallState {
  final String data;

  const CallLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class CallError extends CallState {
  final String message;

  const CallError(this.message);

  @override
  List<Object> get props => [message];
}
