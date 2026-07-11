import 'package:flutter_bloc/flutter_bloc.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  CallBloc() : super(CallInitial()) {
    on<LoadCall>(_onLoadCall);
  }

  Future<void> _onLoadCall(
    LoadCall event,
    Emitter<CallState> emit,
  ) async {
    emit(CallLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(const CallLoaded("Success"));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }
}
