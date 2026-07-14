import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String email;
  final String dob;
  final String gender;
  final String phone;
  final String? avatarUrl;

  const UpdateProfileEvent({
    required this.name,
    required this.email,
    required this.dob,
    required this.gender,
    required this.phone,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [name, email, dob, gender, phone, avatarUrl];
}

class SendProfilePhoneOtp extends ProfileEvent {
  final String phoneNumber;
  const SendProfilePhoneOtp(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyProfilePhoneOtp extends ProfileEvent {
  final String verificationId;
  final String otp;
  const VerifyProfilePhoneOtp(this.verificationId, this.otp);

  @override
  List<Object?> get props => [verificationId, otp];
}
