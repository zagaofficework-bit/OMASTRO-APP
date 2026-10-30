import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object?> get props => [];
}

class ProfileLoaded extends ProfileState {
  final String name;
  final String email;
  final String dob;
  final String gender;
  final String phone;
  final String? avatarUrl;
  final String birthPlace;
  final String birthTime;

  const ProfileLoaded({
    required this.name,
    required this.email,
    required this.dob,
    required this.gender,
    required this.phone,
    this.avatarUrl,
    this.birthPlace = '',
    this.birthTime = '',
  });

  bool get isProfileIncomplete {
    final isPhoneLogin = email.isEmpty || email.startsWith('phone_');
    if (isPhoneLogin) {
      return name.isEmpty || email.isEmpty || dob.isEmpty || gender.isEmpty;
    } else {
      return dob.isEmpty || gender.isEmpty;
    }
  }

  @override
  List<Object?> get props => [
        name,
        email,
        dob,
        gender,
        phone,
        avatarUrl,
        birthPlace,
        birthTime,
      ];
}

class ProfileLoading extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfilePhoneOtpSent extends ProfileState {
  final String verificationId;
  const ProfilePhoneOtpSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}
