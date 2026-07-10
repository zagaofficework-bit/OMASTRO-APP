import 'package:equatable/equatable.dart';

abstract class LiveEvent extends Equatable {
  const LiveEvent();

  @override
  List<Object> get props => [];
}

class LoadLive extends LiveEvent {}
