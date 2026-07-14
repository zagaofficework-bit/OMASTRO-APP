import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
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
          email: event.email,
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
          await Supabase.instance.client
              .from('users')
              .update({
            'full_name': event.name,
            'email': event.email,
            'date_of_birth': event.dob,
            'gender': event.gender,
            'phone': event.phone,
            'avatar_url': updatedAvatar,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', user.id);
        } catch (e) {
          print("Error updating profile: $e");
        }
      }
    });

    on<SendProfilePhoneOtp>((event, emit) async {
      emit(ProfileLoading());
      final completer = Completer<ProfileState>();
      
      try {
        await firebase.FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: event.phoneNumber,
          verificationCompleted: (firebase.PhoneAuthCredential credential) {},
          verificationFailed: (firebase.FirebaseAuthException e) {
            if (!completer.isCompleted) completer.complete(ProfileError(e.message ?? 'Phone verification failed'));
          },
          codeSent: (String verificationId, int? resendToken) {
            if (!completer.isCompleted) completer.complete(ProfilePhoneOtpSent(verificationId));
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );

        final state = await completer.future;
        emit(state);
      } catch (e) {
        emit(ProfileError('Failed to send OTP: ${e.toString()}'));
      }
    });

    on<VerifyProfilePhoneOtp>((event, emit) async {
      emit(ProfileLoading());
      try {
        final credential = firebase.PhoneAuthProvider.credential(
          verificationId: event.verificationId,
          smsCode: event.otp,
        );
        final user = firebase.FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Link the new phone credential to the currently logged in Google user
          await user.linkWithCredential(credential);
          
          // Re-load the profile so UI refreshes and goes back to ProfileLoaded
          add(LoadProfileEvent()); 
        } else {
          emit(const ProfileError('Firebase user not found.'));
        }
      } on firebase.FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked') {
          // The provider has already been linked to the user.
          add(LoadProfileEvent());
        } else if (e.code == 'credential-already-in-use') {
          emit(const ProfileError('This phone number is already linked to another account.'));
        } else {
          emit(ProfileError('Verification failed: ${e.message}'));
        }
      } catch (e) {
        emit(ProfileError('Verification failed: ${e.toString()}'));
      }
    });

    // Automatically load profile on creation
    add(LoadProfileEvent());
  }
}

