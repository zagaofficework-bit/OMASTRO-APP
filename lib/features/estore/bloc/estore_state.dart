import 'package:equatable/equatable.dart';

abstract class EstoreState extends Equatable {
  const EstoreState();
  
  @override
  List<Object> get props => [];
}

class EstoreInitial extends EstoreState {}

class EstoreLoading extends EstoreState {}

class EstoreLoaded extends EstoreState {
  final String data;

  const EstoreLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class EstoreError extends EstoreState {
  final String message;

  const EstoreError(this.message);

  @override
  List<Object> get props => [message];
}
