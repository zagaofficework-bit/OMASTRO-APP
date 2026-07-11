import 'package:equatable/equatable.dart';

/// The events that the ExampleBloc will react to.
abstract class ExampleEvent extends Equatable {
  const ExampleEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when the user wants to load data.
class LoadExampleData extends ExampleEvent {}
