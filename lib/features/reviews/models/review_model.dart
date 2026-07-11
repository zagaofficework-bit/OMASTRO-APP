import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String astrologerName;
  final String userName;
  final double rating;
  final String comment;
  final DateTime timestamp;

  const ReviewModel({
    required this.id,
    required this.astrologerName,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  @override
  List<Object> get props => [id, astrologerName, userName, rating, comment, timestamp];
}
