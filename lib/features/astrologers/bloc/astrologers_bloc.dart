import 'package:flutter_bloc/flutter_bloc.dart';
import 'astrologers_event.dart';
import 'astrologers_state.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class AstrologersBloc extends Bloc<AstrologersEvent, AstrologersState> {
  final _supabase = Supabase.instance.client;

  AstrologersBloc() : super(const AstrologersFollowingState()) {
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
        final List<Map<String, dynamic>> astrologers = List<Map<String, dynamic>>.from(response);
        
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

    on<ToggleFollowAstrologer>((event, emit) {
      final currentState = state;
      if (currentState is AstrologersFollowingState) {
        final List<String> newList = List.from(currentState.followedAstrologers);
        if (newList.contains(event.name)) {
          newList.remove(event.name);
        } else {
          newList.add(event.name);
        }
        emit(AstrologersFollowingState(
          followedAstrologers: newList,
          astrologers: currentState.astrologers,
          isLoading: currentState.isLoading,
        ));
      }
    });
  }
}

