import 'package:equatable/equatable.dart';

abstract class EstoreEvent extends Equatable {
  const EstoreEvent();

  @override
  List<Object> get props => [];
}

class LoadEstore extends EstoreEvent {}
