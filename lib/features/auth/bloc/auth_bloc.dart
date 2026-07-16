import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:omastro/app/route.dart';
import 'package:omastro/core/services/notify_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthLoading()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);

    // Trigger session status check on start
    add(CheckAuthStatus());

    on<SignInRequested>((event, emit) {
      emit(Authenticated());
    });

    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SendPhoneOtpRequested>(_onSendPhoneOtpRequested);
    on<VerifyPhoneOtpRequested>(_onVerifyPhoneOtpRequested);
    on<AstrologerSignInRequested>(_onAstrologerSignIn);
    on<AstrologerSignUpRequested>(_onAstrologerSignUp);

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await google_sign_in.GoogleSignIn.instance.signOut();
        await firebase.FirebaseAuth.instance.signOut();
        await supabase.Supabase.instance.client.auth.signOut();
        
        ZegoUIKitPrebuiltCallInvitationService().uninit();
      } catch (_) {}
      emit(Unauthenticated());
    });
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = firebase.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      emit(Unauthenticated());
      return;
    }

    try {
      final client = supabase.Supabase.instance.client;
      final res = await client
          .from('astrologers')
          .select('id, name, chat_rate, call_rate, video_rate, bio')
          .eq('firebase_uid', currentUser.uid)
          .maybeSingle();

      if (res != null) {
        final chatRate = (res['chat_rate'] as num?)?.toDouble() ?? 0;
        final callRate = (res['call_rate'] as num?)?.toDouble() ?? 0;
        final videoRate = (res['video_rate'] as num?)?.toDouble() ?? 0;
        final bio = res['bio']?.toString() ?? '';

        _initZego(currentUser);

        if (bio.isEmpty && chatRate <= 0 && callRate <= 0 && videoRate <= 0) {
          emit(AstrologerOnboardingRequired(
            astrologerId: res['id'].toString(),
            firebaseUid: currentUser.uid,
            name: res['name']?.toString() ?? '',
          ));
        } else {
          emit(AuthenticatedAsAstrologer(
            astrologerId: res['id'].toString(),
            firebaseUid: currentUser.uid,
            name: res['name']?.toString() ?? '',
          ));
        }
      } else {
        _initZego(currentUser);
        NotifyService.listenForNotifications();
        emit(Authenticated());
      }
    } catch (e) {
      debugPrint('[AuthBloc] CheckAuthStatus error: $e');
      _initZego(currentUser);
      NotifyService.listenForNotifications();
      emit(Authenticated());
    }
  }

  void _initZego(firebase.User user) {
    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(rootNavigatorKey);
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: int.parse(dotenv.env['ZEGO_APP_ID']!),
      appSign: dotenv.env['ZEGO_APP_SIGN']!,
      userID: user.uid,
      userName: user.displayName ?? 'User',
      plugins: [ZegoUIKitSignalingPlugin()],
      requireConfig: (ZegoCallInvitationData data) {
        final config = (data.type == ZegoCallType.videoCall)
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
        
        return config;
      },
    );
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // 1. Trigger Google Sign In
      await google_sign_in.GoogleSignIn.instance.initialize(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );
      final google_sign_in.GoogleSignInAccount? googleUser = await google_sign_in.GoogleSignIn.instance.authenticate();
      
      if (googleUser == null) {
        // User canceled the sign-in flow
        emit(Unauthenticated());
        return;
      }

      // 2. Obtain auth details from the request
      final google_sign_in.GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      
      final authClient = googleUser.authorizationClient;
      final authData = await authClient.authorizationForScopes(['email', 'profile']);
      final accessToken = authData?.accessToken;

      if (idToken == null) {
        emit(const AuthError('Missing Google ID Token'));
        return;
      }

      // 3. Authenticate with Firebase
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      await firebase.FirebaseAuth.instance.signInWithCredential(credential);

      // 4. Authenticate with Supabase
      await supabase.Supabase.instance.client.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // 5. Sync Google User Details to public.profiles table
      final supabaseUser = supabase.Supabase.instance.client.auth.currentUser;
      if (supabaseUser != null) {
        try {
          final profile = await supabase.Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', supabaseUser.id)
              .maybeSingle();

          if (profile == null) {
            // Create profile with details fetched from Google Sign-In
            await supabase.Supabase.instance.client.from('profiles').insert({
              'id': supabaseUser.id,
              'full_name': googleUser.displayName ?? '',
              'email': googleUser.email,
              'avatar_url': googleUser.photoUrl ?? '',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
          } else {
            // Update profile with details from Google only if they are missing/empty in DB
            final Map<String, dynamic> updates = {};
            if ((profile['full_name'] == null || profile['full_name'].toString().isEmpty) && googleUser.displayName != null) {
              updates['full_name'] = googleUser.displayName;
            }
            if (profile['email'] == null || profile['email'].toString().isEmpty) {
              updates['email'] = googleUser.email;
            }
            if ((profile['avatar_url'] == null || profile['avatar_url'].toString().isEmpty) && googleUser.photoUrl != null) {
              updates['avatar_url'] = googleUser.photoUrl;
            }
            
            if (updates.isNotEmpty) {
              updates['updated_at'] = DateTime.now().toIso8601String();
              await supabase.Supabase.instance.client.from('profiles').update(updates).eq('id', supabaseUser.id);
            }
          }
        } catch (dbError) {
          print("Error syncing Google profile to Supabase: $dbError");
        }
      }

      _initZego(firebase.FirebaseAuth.instance.currentUser!);
      emit(Authenticated());
    } catch (e) {
      String errorMessage = 'Authentication failed. Please try again.';
      final errorStr = e.toString();
      
      if (errorStr.contains('SocketException') || errorStr.contains('Network') || errorStr.contains('Connection timed out') || errorStr.contains('host-lookup')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      } else if (errorStr.contains('canceled') || errorStr.contains('cancelled')) {
        errorMessage = 'Sign-in was cancelled.';
      } else if (errorStr.contains('16') || errorStr.contains('reauth failed') || errorStr.contains('DEVELOPER_ERROR')) {
        errorMessage = 'Google account verification failed. Please verify your internet connection or Google Account settings on this device.';
      } else if (e is firebase.FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      }
      
      emit(AuthError(errorMessage));
    }
  }

  String _generateDeterministicPassword(String phoneNumber) {
    final salt = dotenv.env['PHONE_AUTH_SECRET_SALT'] ?? 'default_omastro_salt_9191';
    final bytes = utf8.encode(phoneNumber + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _onSendPhoneOtpRequested(
    SendPhoneOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final completer = Completer<AuthState>();

    try {
      await firebase.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        verificationCompleted: (firebase.PhoneAuthCredential credential) async {
          // Automatic resolution (e.g. on Android)
          // We can't easily emit here because the original event handler might have finished,
          // but we can just let it timeout or user can press verify manually.
        },
        verificationFailed: (firebase.FirebaseAuthException e) {
          if (!completer.isCompleted) completer.complete(AuthError(e.message ?? 'Phone verification failed'));
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) completer.complete(PhoneOtpSentState(verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );

      final state = await completer.future;
      emit(state);
    } catch (e) {
      emit(AuthError('Failed to send OTP: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyPhoneOtpRequested(
    VerifyPhoneOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // 1. Verify with Firebase
      final credential = firebase.PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.otp,
      );
      final userCredential = await firebase.FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw Exception('Firebase user is null');

      // 2. Authenticate with Supabase deterministically
      final dummyEmail = 'phone_${user.phoneNumber?.replaceAll('+', '') ?? 'unknown'}@gmail.com';
      final password = _generateDeterministicPassword(user.phoneNumber ?? 'unknown');

      try {
        await supabase.Supabase.instance.client.auth.signInWithPassword(
          email: dummyEmail,
          password: password,
        );
      } on supabase.AuthException catch (e) {
        if (e.message.contains('Invalid login credentials') || e.statusCode == 400) {
          // User doesn't exist, sign them up
          await supabase.Supabase.instance.client.auth.signUp(
            email: dummyEmail,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      _initZego(user);
      emit(Authenticated());
    } catch (e) {
      emit(AuthError('Verification failed: ${e.toString()}'));
    }
  }

  // ── Astrologer Authentication ──

  Future<void> _onAstrologerSignIn(
    AstrologerSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // 1. Sign in with Firebase (email/password)
      final firebaseCred = await firebase.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: event.email, password: event.password);
      final firebaseUser = firebaseCred.user;
      if (firebaseUser == null) throw Exception('Firebase sign-in returned null user');

      debugPrint('[AuthBloc] Astrologer Firebase sign-in success: ${firebaseUser.uid}');

      // 2. Sign in with Supabase (mirror account)
      try {
        await supabase.Supabase.instance.client.auth.signInWithPassword(
          email: event.email,
          password: event.password,
        );
      } on supabase.AuthException catch (e) {
        if (e.message.contains('Invalid login credentials') || e.statusCode == 400) {
          // First time: create Supabase auth account
          await supabase.Supabase.instance.client.auth.signUp(
            email: event.email,
            password: event.password,
          );
        } else {
          rethrow;
        }
      }

      // 3. Look up astrologer profile in Supabase
      final astrologerRow = await _findOrCreateAstrologerRow(
        firebaseUid: firebaseUser.uid,
        name: firebaseUser.displayName ?? event.email.split('@').first,
      );

      _initZego(firebaseUser);

      // 4. Check if onboarding is complete (rates are set and not all default zeros)
      final chatRate = (astrologerRow['chat_rate'] as num?)?.toDouble() ?? 0;
      final callRate = (astrologerRow['call_rate'] as num?)?.toDouble() ?? 0;
      final videoRate = (astrologerRow['video_rate'] as num?)?.toDouble() ?? 0;
      final bio = astrologerRow['bio']?.toString() ?? '';

      if (bio.isEmpty && chatRate <= 0 && callRate <= 0 && videoRate <= 0) {
        emit(AstrologerOnboardingRequired(
          astrologerId: astrologerRow['id'].toString(),
          firebaseUid: firebaseUser.uid,
          name: astrologerRow['name']?.toString() ?? '',
        ));
      } else {
        emit(AuthenticatedAsAstrologer(
          astrologerId: astrologerRow['id'].toString(),
          firebaseUid: firebaseUser.uid,
          name: astrologerRow['name']?.toString() ?? '',
        ));
      }
    } catch (e) {
      debugPrint('[AuthBloc] Astrologer sign-in error: $e');
      emit(AuthError('Astrologer sign-in failed: ${e.toString()}'));
    }
  }

  Future<void> _onAstrologerSignUp(
    AstrologerSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // 1. Create Firebase auth account
      final firebaseCred = await firebase.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: event.email, password: event.password);
      final firebaseUser = firebaseCred.user;
      if (firebaseUser == null) throw Exception('Firebase sign-up returned null user');
      await firebaseUser.updateDisplayName(event.name);

      debugPrint('[AuthBloc] Astrologer Firebase sign-up success: ${firebaseUser.uid}');

      // 2. Create Supabase auth account
      try {
        await supabase.Supabase.instance.client.auth.signUp(
          email: event.email,
          password: event.password,
        );
      } on supabase.AuthException catch (e) {
        // If account already exists, just sign in
        if (e.statusCode == 400) {
          await supabase.Supabase.instance.client.auth.signInWithPassword(
            email: event.email,
            password: event.password,
          );
        } else {
          rethrow;
        }
      }

      // 3. Insert astrologer row
      final inserted = await supabase.Supabase.instance.client
          .from('astrologers')
          .insert({
            'name': event.name,
            'firebase_uid': firebaseUser.uid,
            'bio': '',
            'experience_years': 0,
            'languages': <String>[],
            'skills': <String>[],
            'categories': <String>[],
            'price_per_minute': 0,
            'chat_rate': 0,
            'call_rate': 0,
            'video_rate': 0,
          })
          .select()
          .single();

      _initZego(firebaseUser);

      emit(AstrologerOnboardingRequired(
        astrologerId: inserted['id'].toString(),
        firebaseUid: firebaseUser.uid,
        name: event.name,
      ));
    } catch (e) {
      debugPrint('[AuthBloc] Astrologer sign-up error: $e');
      emit(AuthError('Astrologer sign-up failed: ${e.toString()}'));
    }
  }

  /// Find astrologer row by firebase_uid, or create one if missing
  Future<Map<String, dynamic>> _findOrCreateAstrologerRow({
    required String firebaseUid,
    required String name,
  }) async {
    final client = supabase.Supabase.instance.client;

    // Try to find existing row
    final existing = await client
        .from('astrologers')
        .select()
        .eq('firebase_uid', firebaseUid)
        .maybeSingle();

    if (existing != null) return existing;

    // Not found — create a new row
    debugPrint('[AuthBloc] No astrologer row found for firebase_uid=$firebaseUid, creating...');
    final inserted = await client
        .from('astrologers')
        .insert({
          'name': name,
          'firebase_uid': firebaseUid,
          'bio': '',
          'experience_years': 0,
          'languages': <String>[],
          'skills': <String>[],
          'categories': <String>[],
          'price_per_minute': 0,
          'chat_rate': 0,
          'call_rate': 0,
          'video_rate': 0,
        })
        .select()
        .single();

    return inserted;
  }
}

final globalAuthBloc = AuthBloc();
