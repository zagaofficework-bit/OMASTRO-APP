import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String dob;
  final String gender;
  final String phone;
  final String? avatarUrl;

  const UpdateProfileEvent({
    required this.name,
    required this.dob,
    required this.gender,
    required this.phone,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [name, dob, gender, phone, avatarUrl];
}

