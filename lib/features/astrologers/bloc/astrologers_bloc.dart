import 'package:flutter_bloc/flutter_bloc.dart';
import 'astrologers_event.dart';
import 'astrologers_state.dart';

class AstrologersBloc extends Bloc<AstrologersEvent, AstrologersState> {
  AstrologersBloc() : super(const AstrologersFollowingState()) {
    on<ToggleFollowAstrologer>((event, emit) {
      final currentState = state;
      if (currentState is AstrologersFollowingState) {
        final List<String> newList = List.from(currentState.followedAstrologers);
        if (newList.contains(event.name)) {
          newList.remove(event.name);
        } else {
          newList.add(event.name);
        }
        emit(AstrologersFollowingState(followedAstrologers: newList));
      }
    });
  }
}

