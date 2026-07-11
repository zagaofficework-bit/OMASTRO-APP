import 'package:equatable/equatable.dart';

abstract class LiveState extends Equatable {
  const LiveState();
  
  @override
  List<Object> get props => [];
}

class LiveInitial extends LiveState {}

class LiveLoading extends LiveState {}

class LiveLoaded extends LiveState {
  final String data;

  const LiveLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class LiveError extends LiveState {
  final String message;

  const LiveError(this.message);

  @override
  List<Object> get props => [message];
}
