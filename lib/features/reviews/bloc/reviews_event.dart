import 'package:equatable/equatable.dart';
import '../models/review_model.dart';

abstract class ReviewsEvent extends Equatable {
  const ReviewsEvent();

  @override
  List<Object> get props => [];
}

class AddReviewEvent extends ReviewsEvent {
  final ReviewModel review;

  const AddReviewEvent(this.review);

  @override
  List<Object> get props => [review];
}

class LoadReviewsForAstrologer extends ReviewsEvent {
  final String astrologerId;

  const LoadReviewsForAstrologer(this.astrologerId);

  @override
  List<Object> get props => [astrologerId];
}
