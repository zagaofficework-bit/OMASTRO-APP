import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// Regular user is authenticated
class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class PhoneOtpSentState extends AuthState {
  final String verificationId;

  const PhoneOtpSentState(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

// ── Astrologer-Specific States ──

/// Astrologer authenticated and profile is complete
class AuthenticatedAsAstrologer extends AuthState {
  final String astrologerId; // Supabase astrologers.id
  final String firebaseUid;
  final String name;

  const AuthenticatedAsAstrologer({
    required this.astrologerId,
    required this.firebaseUid,
    required this.name,
  });

  @override
  List<Object?> get props => [astrologerId, firebaseUid, name];
}

/// Astrologer authenticated but onboarding not complete (rates not set)
class AstrologerOnboardingRequired extends AuthState {
  final String astrologerId;
  final String firebaseUid;
  final String name;

  const AstrologerOnboardingRequired({
    required this.astrologerId,
    required this.firebaseUid,
    required this.name,
  });

  @override
  List<Object?> get props => [astrologerId, firebaseUid, name];
}
