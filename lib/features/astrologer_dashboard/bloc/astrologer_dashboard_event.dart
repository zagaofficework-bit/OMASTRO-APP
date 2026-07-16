import 'package:equatable/equatable.dart';

abstract class AstrologerDashboardEvent extends Equatable {
  const AstrologerDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadAstrologerDashboard extends AstrologerDashboardEvent {
  final String astrologerId;
  final String firebaseUid;
  const LoadAstrologerDashboard({required this.astrologerId, required this.firebaseUid});

  @override
  List<Object?> get props => [astrologerId, firebaseUid];
}

class ToggleOnlineStatus extends AstrologerDashboardEvent {}

class UpdateAstrologerProfile extends AstrologerDashboardEvent {
  final Map<String, dynamic> updates;
  const UpdateAstrologerProfile(this.updates);

  @override
  List<Object?> get props => [updates];
}
