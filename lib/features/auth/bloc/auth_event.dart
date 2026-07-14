import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInRequested extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class SendPhoneOtpRequested extends AuthEvent {
  final String phoneNumber;
  const SendPhoneOtpRequested(this.phoneNumber);
  
  @override
  List<Object> get props => [phoneNumber];
}

class VerifyPhoneOtpRequested extends AuthEvent {
  final String verificationId;
  final String otp;
  const VerifyPhoneOtpRequested(this.verificationId, this.otp);

  @override
  List<Object> get props => [verificationId, otp];
}

class SignOutRequested extends AuthEvent {}
