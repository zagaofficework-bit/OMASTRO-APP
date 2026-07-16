import 'package:equatable/equatable.dart';

abstract class AstrologerDashboardState extends Equatable {
  const AstrologerDashboardState();
  @override
  List<Object?> get props => [];
}

class AstrologerDashboardInitial extends AstrologerDashboardState {}

class AstrologerDashboardLoading extends AstrologerDashboardState {}

class AstrologerDashboardLoaded extends AstrologerDashboardState {
  final String astrologerId;
  final String firebaseUid;
  final String name;
  final String bio;
  final int experienceYears;
  final List<String> languages;
  final List<String> skills;
  final List<String> categories;
  final double chatRate;
  final double callRate;
  final double videoRate;
  final double rating;
  final int reviewsCount;
  final int totalMinutesConsulted;
  final bool isOnline;
  final String? avatarUrl;

  const AstrologerDashboardLoaded({
    required this.astrologerId,
    required this.firebaseUid,
    required this.name,
    required this.bio,
    required this.experienceYears,
    required this.languages,
    required this.skills,
    required this.categories,
    required this.chatRate,
    required this.callRate,
    required this.videoRate,
    required this.rating,
    required this.reviewsCount,
    required this.totalMinutesConsulted,
    required this.isOnline,
    this.avatarUrl,
  });

  AstrologerDashboardLoaded copyWith({
    bool? isOnline,
    String? name,
    String? bio,
    double? chatRate,
    double? callRate,
    double? videoRate,
  }) {
    return AstrologerDashboardLoaded(
      astrologerId: astrologerId,
      firebaseUid: firebaseUid,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      experienceYears: experienceYears,
      languages: languages,
      skills: skills,
      categories: categories,
      chatRate: chatRate ?? this.chatRate,
      callRate: callRate ?? this.callRate,
      videoRate: videoRate ?? this.videoRate,
      rating: rating,
      reviewsCount: reviewsCount,
      totalMinutesConsulted: totalMinutesConsulted,
      isOnline: isOnline ?? this.isOnline,
      avatarUrl: avatarUrl,
    );
  }

  @override
  List<Object?> get props => [
    astrologerId, firebaseUid, name, bio, experienceYears, languages, skills,
    categories, chatRate, callRate, videoRate, rating, reviewsCount,
    totalMinutesConsulted, isOnline, avatarUrl,
  ];
}

class AstrologerDashboardError extends AstrologerDashboardState {
  final String message;
  const AstrologerDashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
