import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(Unauthenticated()) {
    on<SignInRequested>((event, emit) {
      emit(Authenticated());
    });

    on<SignOutRequested>((event, emit) {
      emit(Unauthenticated());
    });
  }
}

final globalAuthBloc = AuthBloc();

