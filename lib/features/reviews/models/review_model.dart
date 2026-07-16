import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String astrologerId;
  final String astrologerName;
  final String userName;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final String? reviewerAvatar;

  const ReviewModel({
    required this.id,
    required this.astrologerId,
    required this.astrologerName,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.reviewerAvatar,
  });

  factory ReviewModel.fromSupabase(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map?;
    final uName = profiles != null 
        ? (profiles['full_name']?.toString() ?? 'Anonymous') 
        : (json['user_name']?.toString() ?? 'Anonymous');
    final avatar = profiles != null 
        ? profiles['avatar_url']?.toString() 
        : json['reviewer_avatar']?.toString();

    return ReviewModel(
      id: json['id']?.toString() ?? '',
      astrologerId: json['astrologer_id']?.toString() ?? '',
      astrologerName: json['astrologer_name']?.toString() ?? '',
      userName: uName,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment']?.toString() ?? json['review_text']?.toString() ?? '',
      timestamp: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
      reviewerAvatar: avatar,
    );
  }

  @override
  List<Object?> get props => [
        id,
        astrologerId,
        astrologerName,
        userName,
        rating,
        comment,
        timestamp,
        reviewerAvatar,
      ];
}
