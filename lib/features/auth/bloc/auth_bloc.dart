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

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(supabase.Supabase.instance.client.auth.currentSession != null ? Authenticated() : Unauthenticated()) {
    final currentUser = firebase.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _initZego(currentUser);
    }

    on<SignInRequested>((event, emit) {
      emit(Authenticated());
    });

    on<GoogleSignInRequested>(_onGoogleSignInRequested);

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

      _initZego(firebase.FirebaseAuth.instance.currentUser!);
      emit(Authenticated());
    } catch (e) {
      emit(AuthError('Authentication failed: ${e.toString()}'));
    }
  }
}

final globalAuthBloc = AuthBloc();
