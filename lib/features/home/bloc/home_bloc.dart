import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHome>(_onLoadHome);
  }

  Future<void> _onLoadHome(
    LoadHome event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(const HomeLoaded("Success"));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
