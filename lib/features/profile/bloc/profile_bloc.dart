import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final _supabase = Supabase.instance.client;

  ProfileBloc()
      : super(const ProfileLoaded(
          name: '',
          email: '',
          dob: '',
          gender: '',
          phone: '',
        )) {
    
    on<LoadProfileEvent>((event, emit) async {
      try {
        final user = _supabase.auth.currentUser;
        if (user == null) return;
        
        final userId = user.id;
        final response = await _supabase.from('profiles').select().eq('id', userId).maybeSingle();
        
        final metadata = user.userMetadata ?? {};
        final authEmail = user.email ?? '';
        final authName = metadata['full_name'] ?? metadata['name'] ?? '';
        final authAvatar = metadata['avatar_url'] ?? metadata['picture'];

        if (response != null) {
          emit(ProfileLoaded(
            name: (response['full_name'] == null || response['full_name'].toString().isEmpty) ? authName : response['full_name'],
            email: (response['email'] == null || response['email'].toString().isEmpty) ? authEmail : response['email'],
            dob: response['date_of_birth'] ?? '',
            gender: response['gender'] ?? '',
            phone: response['phone'] ?? '',
            avatarUrl: response['avatar_url'] ?? authAvatar,
          ));
        } else {
          emit(ProfileLoaded(
            name: authName,
            email: authEmail,
            dob: '',
            gender: '',
            phone: '',
            avatarUrl: authAvatar,
          ));
        }
      } catch (e) {
        print("Error loading profile: $e");
      }
    });

    on<UpdateProfileEvent>((event, emit) async {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        final updatedAvatar = event.avatarUrl ?? currentState.avatarUrl;
        
        // Optimistically emit new state
        emit(ProfileLoaded(
          name: event.name,
          email: currentState.email,
          dob: event.dob,
          gender: event.gender,
          phone: event.phone,
          avatarUrl: updatedAvatar,
        ));

        // Save to Supabase
        try {
          final user = _supabase.auth.currentUser;
          if (user == null) return;
          
          final userId = user.id;
          await _supabase.from('profiles').upsert({
            'id': userId,
            'full_name': event.name,
            'email': currentState.email,
            'date_of_birth': event.dob,
            'gender': event.gender,
            'phone': event.phone,
            if (updatedAvatar != null) 'avatar_url': updatedAvatar,
          });
        } catch (e) {
          print("Error updating profile: $e");
        }
      }
    });

    // Automatically load profile on creation
    add(LoadProfileEvent());
  }
}

