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
