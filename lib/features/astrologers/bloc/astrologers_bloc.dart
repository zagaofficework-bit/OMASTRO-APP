import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'astrologers_event.dart';
import 'astrologers_state.dart';
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AstrologersBloc extends Bloc<AstrologersEvent, AstrologersState> {
  final _supabase = Supabase.instance.client;
  StreamSubscription<QuerySnapshot>? _presenceSubscription;

  AstrologersBloc() : super(const AstrologersFollowingState()) {
    _subscribeToFirestorePresence();

    on<LoadAstrologers>((event, emit) async {
      final currentState = state;
      if (currentState is AstrologersFollowingState) {
        emit(AstrologersFollowingState(
          followedAstrologers: currentState.followedAstrologers,
          astrologers: currentState.astrologers,
          isLoading: true,
        ));
      } else {
        emit(const AstrologersFollowingState(isLoading: true));
      }

      try {
        final response = await _supabase.from('astrologers').select();
        final List<Map<String, dynamic>> astrologers = (response as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        // 1. Fetch current Firestore presence statuses
        final presenceSnap = await FirebaseFirestore.instance.collection('presence').get();
        final Map<String, bool> presenceMap = {};
        for (final doc in presenceSnap.docs) {
          presenceMap[doc.id] = doc.data()['is_online'] as bool? ?? false;
        }

        // 2. Map dynamic is_online status to the list
        for (final astro in astrologers) {
          final firebaseUid = astro['firebase_uid']?.toString() ?? '';
          astro['is_online'] = presenceMap[firebaseUid] ?? false;
        }
        
        if (astrologers.isNotEmpty) {
          debugPrint('[AstrologersBloc] Fetched ${astrologers.length} astrologers with Firestore presence.');
        }

        // Sort astrologers by a simple "Top Astrologer" score: 
        // Score = (Rating * ReviewsCount) + TotalMinutes
        astrologers.sort((a, b) {
          final ratingA = (a['rating'] as num?)?.toDouble() ?? 0.0;
          final ratingB = (b['rating'] as num?)?.toDouble() ?? 0.0;
          final reviewsA = (a['reviews_count'] as num?)?.toInt() ?? 0;
          final reviewsB = (b['reviews_count'] as num?)?.toInt() ?? 0;
          final minsA = (a['total_minutes_consulted'] as num?)?.toInt() ?? 0;
          final minsB = (b['total_minutes_consulted'] as num?)?.toInt() ?? 0;

          final scoreA = (ratingA * reviewsA) + (minsA * 0.1); 
          final scoreB = (ratingB * reviewsB) + (minsB * 0.1); 
          return scoreB.compareTo(scoreA); // Descending order
        });

        if (state is AstrologersFollowingState) {
          emit(AstrologersFollowingState(
            followedAstrologers: (state as AstrologersFollowingState).followedAstrologers,
            astrologers: astrologers,
            isLoading: false,
          ));
        }
      } catch (e) {
        print("Error loading astrologers: $e");
        if (state is AstrologersFollowingState) {
          emit(AstrologersFollowingState(
            followedAstrologers: (state as AstrologersFollowingState).followedAstrologers,
            astrologers: (state as AstrologersFollowingState).astrologers,
            isLoading: false,
          ));
        }
      }
    });
  }

  void _subscribeToFirestorePresence() {
    try {
      _presenceSubscription = FirebaseFirestore.instance
          .collection('presence')
          .snapshots()
          .listen((snapshot) {
        debugPrint('[AstrologersBloc] Realtime Firestore presence change detected.');
        add(LoadAstrologers()); 
      });
    } catch (e) {
      debugPrint('[AstrologersBloc] Error setting up Firestore presence listener: $e');
    }
  }

  @override
  Future<void> close() {
    _presenceSubscription?.cancel();
    return super.close();
  }
}
