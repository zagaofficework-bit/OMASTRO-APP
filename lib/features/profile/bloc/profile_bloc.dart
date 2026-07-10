import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc()
      : super(const ProfileLoaded(
          name: 'Satvik Dev',
          email: 'satvik.it.dev@gmail.com',
          dob: '15 May 1995',
          gender: 'Male',
          phone: '+91 9876543210',
        )) {
    on<UpdateProfileEvent>((event, emit) {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        emit(ProfileLoaded(
          name: event.name,
          email: currentState.email,
          dob: event.dob,
          gender: event.gender,
          phone: currentState.phone,
        ));
      }
    });
  }
}

