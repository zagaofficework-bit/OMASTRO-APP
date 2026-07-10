import 'package:flutter_bloc/flutter_bloc.dart';
import 'live_event.dart';
import 'live_state.dart';

class LiveBloc extends Bloc<LiveEvent, LiveState> {
  LiveBloc() : super(LiveInitial()) {
    on<LoadLive>(_onLoadLive);
  }

  Future<void> _onLoadLive(
    LoadLive event,
    Emitter<LiveState> emit,
  ) async {
    emit(LiveLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(const LiveLoaded("Success"));
    } catch (e) {
      emit(LiveError(e.toString()));
    }
  }
}
