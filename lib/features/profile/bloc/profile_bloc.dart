import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final _supabase = Supabase.instance.client;

  String _extractNameFromEmail(String rawEmail) {
    if (rawEmail.isEmpty || !rawEmail.contains('@') || rawEmail.startsWith('phone_')) return 'User';
    String localPart = rawEmail.split('@').first;
    String cleanedName = localPart.replaceAll(RegExp(r'[._-]'), ' ');
    cleanedName = cleanedName.replaceAll(RegExp(r'\d'), '');
    return cleanedName
        .trim()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ')
        .trim();
  }

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

        // If email is dummy phone email, extract phone number and treat email as empty
        final isPhoneAuth = authEmail.startsWith('phone_');
        String extractedPhone = '';
        if (isPhoneAuth) {
          try {
            final rawNum = authEmail.split('_')[1].split('@')[0];
            extractedPhone = rawNum.startsWith('+') ? rawNum : '+$rawNum';
          } catch (_) {}
        }
        if (extractedPhone.isEmpty) {
          extractedPhone = firebase.FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
        }

        final defaultName = (authName.toString().isEmpty) 
            ? (isPhoneAuth ? 'User' : _extractNameFromEmail(authEmail)) 
            : authName;

        if (response != null) {
          final dbPhone = response['phone'] ?? '';
          final finalPhone = (dbPhone.toString().isEmpty) ? extractedPhone : dbPhone;
          
          final dbEmail = response['email'] ?? '';
          final finalEmail = (dbEmail.toString().isEmpty || dbEmail.toString().startsWith('phone_')) 
              ? (isPhoneAuth ? '' : authEmail) 
              : dbEmail;

          final dbName = response['full_name'] ?? '';
          final finalName = (dbName.toString().isEmpty) ? defaultName : dbName;

          emit(ProfileLoaded(
            name: finalName,
            email: finalEmail,
            dob: response['date_of_birth'] ?? '',
            gender: response['gender'] ?? '',
            phone: finalPhone,
            avatarUrl: response['avatar_url'] ?? authAvatar,
          ));
        } else {
          emit(ProfileLoaded(
            name: defaultName,
            email: isPhoneAuth ? '' : authEmail,
            dob: '',
            gender: '',
            phone: extractedPhone,
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
              .from('profiles')
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

