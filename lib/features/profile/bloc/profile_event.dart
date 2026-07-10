import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String dob;
  final String gender;

  const UpdateProfileEvent({
    required this.name,
    required this.dob,
    required this.gender,
  });

  @override
  List<Object> get props => [name, dob, gender];
}

