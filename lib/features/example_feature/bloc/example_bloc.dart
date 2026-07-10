import 'package:flutter_bloc/flutter_bloc.dart';
import 'example_event.dart';
import 'example_state.dart';

/// The ExampleBloc handles business logic for the Example feature.
/// It receives [ExampleEvent]s and emits [ExampleState]s.
class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  ExampleBloc() : super(ExampleInitial()) {
    // Register the handler for LoadExampleData event
    on<LoadExampleData>(_onLoadExampleData);
  }

  /// Handler for the [LoadExampleData] event.
  Future<void> _onLoadExampleData(
    LoadExampleData event,
    Emitter<ExampleState> emit,
  ) async {
    // 1. Emit loading state
    emit(ExampleLoading());

    try {
      // 2. Simulate a network request or database call
      await Future.delayed(const Duration(seconds: 2));

      // 3. Emit success state with data
      emit(const ExampleLoaded("Hello from Clean Architecture Bloc!"));
    } catch (e) {
      // 4. Emit error state if something goes wrong
      emit(ExampleError("Failed to load data: $e"));
    }
  }
}
