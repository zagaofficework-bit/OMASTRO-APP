import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_screen_event.dart';
import 'splash_screen_state.dart';

class SplashScreenBloc extends Bloc<SplashScreenEvent, SplashScreenState> {
  SplashScreenBloc() : super(SplashScreenInitial()) {
    on<LoadSplashScreen>(_onLoadSplashScreen);
  }

  Future<void> _onLoadSplashScreen(
    LoadSplashScreen event,
    Emitter<SplashScreenState> emit,
  ) async {
    emit(SplashScreenLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(const SplashScreenLoaded("Success"));
    } catch (e) {
      emit(SplashScreenError(e.toString()));
    }
  }
}
