import 'package:equatable/equatable.dart';

/// Represents the different states of the Example feature.
abstract class ExampleState extends Equatable {
  const ExampleState();
  
  @override
  List<Object> get props => [];
}

/// The initial state before any action is taken.
class ExampleInitial extends ExampleState {}

/// State while data is being loaded.
class ExampleLoading extends ExampleState {}

/// State when data is successfully loaded.
class ExampleLoaded extends ExampleState {
  final String data;

  const ExampleLoaded(this.data);

  @override
  List<Object> get props => [data];
}

/// State when an error occurs.
class ExampleError extends ExampleState {
  final String message;

  const ExampleError(this.message);

  @override
  List<Object> get props => [message];
}
