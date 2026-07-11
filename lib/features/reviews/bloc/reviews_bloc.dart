import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/review_model.dart';
import 'reviews_event.dart';
import 'reviews_state.dart';

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  ReviewsBloc() : super(ReviewsUpdatedState(reviews: _initialReviews())) {
    on<AddReviewEvent>((event, emit) {
      final currentState = state;
      if (currentState is ReviewsUpdatedState) {
        final newReviewsMap = Map<String, List<ReviewModel>>.from(currentState.reviews);
        
        final astrologerReviews = List<ReviewModel>.from(newReviewsMap[event.review.astrologerName] ?? []);
        // Prepend the new review so it appears at the top
        astrologerReviews.insert(0, event.review);
        newReviewsMap[event.review.astrologerName] = astrologerReviews;

        emit(ReviewsUpdatedState(reviews: newReviewsMap));
      }
    });
  }

  static Map<String, List<ReviewModel>> _initialReviews() {
    // Generate some generic mock reviews for any astrologer profile opened
    final mockReview1 = ReviewModel(
      id: 'rev_1',
      astrologerName: 'Generic', 
      userName: 'Rohan K.',
      rating: 5.0,
      comment: 'Very accurate prediction! Highly recommended.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    );
    
    final mockReview2 = ReviewModel(
      id: 'rev_2',
      astrologerName: 'Generic',
      userName: 'Neha S.',
      rating: 5.0,
      comment: 'Felt so peaceful talking to her. Clean explanations and remediation guides.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    );

    // Instead of hardcoding all astrologers, we'll just populate an initial list 
    // and copy it when a specific astrologer's reviews are requested in the UI.
    return {
      'DEFAULT': [mockReview1, mockReview2]
    };
  }
}
