import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/review_model.dart';
import 'reviews_event.dart';
import 'reviews_state.dart';

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  final _supabase = Supabase.instance.client;

  ReviewsBloc() : super(const ReviewsUpdatedState(reviews: {})) {
    
    on<LoadReviewsForAstrologer>((event, emit) async {
      try {
        final res = await _supabase
            .from('astrologer_reviews')
            .select('*, profiles(full_name, avatar_url)')
            .eq('astrologer_id', event.astrologerId)
            .order('created_at', ascending: false);

        final reviewsList = (res as List)
            .map((j) => ReviewModel.fromSupabase(Map<String, dynamic>.from(j as Map)))
            .toList();
        final currentMap = state is ReviewsUpdatedState 
            ? Map<String, List<ReviewModel>>.from((state as ReviewsUpdatedState).reviews) 
            : <String, List<ReviewModel>>{};

        currentMap[event.astrologerId] = reviewsList;
        emit(ReviewsUpdatedState(reviews: currentMap));
      } catch (e) {
        print('Error loading reviews: $e');
      }
    });

    on<AddReviewEvent>((event, emit) async {
      try {
        final user = _supabase.auth.currentUser;
        if (user == null) return;

        // Insert into Supabase table public.astrologer_reviews
        await _supabase.from('astrologer_reviews').insert({
          'astrologer_id': event.review.astrologerId,
          'user_id': user.id,
          'reviewer_name': event.review.userName,
          if (event.review.reviewerAvatar != null) 'reviewer_avatar': event.review.reviewerAvatar,
          'rating': event.review.rating,
          'comment': event.review.comment,
        });

        // Fetch all reviews to recalculate rating and count
        final reviewsResponse = await _supabase
            .from('astrologer_reviews')
            .select('rating')
            .eq('astrologer_id', event.review.astrologerId);
            
        final reviews = reviewsResponse as List;
        final int count = reviews.length;
        double totalRating = 0;
        for (var r in reviews) {
          totalRating += (r['rating'] as num).toDouble();
        }
        final double averageRating = count > 0 ? (totalRating / count) : 5.0;

        // Update astrologers table
        await _supabase.from('astrologers').update({
          'reviews_count': count,
          'rating': averageRating,
        }).eq('id', event.review.astrologerId);

        // Trigger load to refresh the reviews list for this astrologer
        add(LoadReviewsForAstrologer(event.review.astrologerId));
      } catch (e) {
        print('Error adding review: $e');
      }
    });
  }
}
