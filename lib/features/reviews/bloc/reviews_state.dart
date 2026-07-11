import 'package:equatable/equatable.dart';
import '../models/review_model.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();
  
  @override
  List<Object> get props => [];
}

class ReviewsUpdatedState extends ReviewsState {
  final Map<String, List<ReviewModel>> reviews;

  const ReviewsUpdatedState({required this.reviews});

  @override
  List<Object> get props => [reviews];
}
