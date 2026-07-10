import 'package:flutter_bloc/flutter_bloc.dart';
import 'estore_event.dart';
import 'estore_state.dart';

class EstoreBloc extends Bloc<EstoreEvent, EstoreState> {
  EstoreBloc() : super(EstoreInitial()) {
    on<LoadEstore>(_onLoadEstore);
  }

  Future<void> _onLoadEstore(
    LoadEstore event,
    Emitter<EstoreState> emit,
  ) async {
    emit(EstoreLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(const EstoreLoaded("Success"));
    } catch (e) {
      emit(EstoreError(e.toString()));
    }
  }
}
