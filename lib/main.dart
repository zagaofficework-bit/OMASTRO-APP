import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omastro/core/bloc/app_bloc_observer.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import 'package:omastro/core/theme/app_theme.dart';
import 'package:omastro/core/services/notification_service.dart';
import 'package:omastro/core/services/permission_service.dart';
import 'package:omastro/core/services/onboarding_service.dart';
import 'app/route.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/wallet/bloc/wallet_bloc.dart';
import 'features/wallet/bloc/wallet_event.dart';
import 'features/profile/bloc/profile_bloc.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/astrologers/bloc/astrologers_bloc.dart';
import 'features/astrologers/bloc/astrologers_event.dart';
import 'features/reviews/bloc/reviews_bloc.dart';
import 'features/astrologer_dashboard/bloc/astrologer_dashboard_bloc.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'features/call/widgets/incoming_call_listener.dart';

import 'package:omastro/core/utils/firestore_sync_helper.dart';
import 'package:omastro/core/services/background_notification_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // 1. Lock the screen on cold boot
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize dotenv and Supabase
  try {
    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '',
    );
  } catch (e) {
    debugPrint('[main] Supabase / dotenv init error: $e');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[main] Firebase init error: $e');
  }

  // Sync astrologers from Supabase to Firestore asynchronously
  try {
    FirestoreSyncHelper.syncAstrologersToFirestore();
  } catch (e) {
    debugPrint('[main] FirestoreSyncHelper error: $e');
  }

  // Initialize background notification service
  try {
    await initBackgroundNotificationService();
  } catch (e) {
    debugPrint('[main] initBackgroundNotificationService error: $e');
  }

  // Register FCM background message handler (works when app is background/terminated)
  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('[main] FirebaseMessaging background handler error: $e');
  }

  // Initialize Google Sign-In with Web Client ID for Supabase validation
  try {
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    await google_sign_in.GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? webClientId : null,
      serverClientId: webClientId,
    );
  } catch (e) {
    debugPrint('[main] GoogleSignIn init error: $e');
  }

  // Initialize the global BlocObserver for tracking state changes
  Bloc.observer = AppBlocObserver();

  // Initialize Notifications & FCM
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('[main] NotificationService init error: $e');
  }

  // Initialize Onboarding status cache
  try {
    await OnboardingService.init();
  } catch (e) {
    debugPrint('[main] OnboardingService init error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 2. Safely release the splash screen on the next frame loop cycle
    removeSplash();
    // Request app permissions after the first frame has rendered safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionService.requestAppPermissions();
    });
  }

  void removeSplash() async {
    // Keep splash on screen for 2 full seconds so the user sees it cleanly
    await Future.delayed(const Duration(milliseconds: 2000));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => WalletBloc()..add(LoadWallet())),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => ChatBloc(), lazy: false),
        BlocProvider(create: (_) => AstrologersBloc()..add(LoadAstrologers())),
        BlocProvider(create: (_) => ReviewsBloc()),
        BlocProvider(create: (_) => AstrologerDashboardBloc()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        builder: (context, child) {
          return Container(
            color: const Color(0xFFFFFBF2), // Force app base background color to prevent flash
            child: Stack(
              children: [
                IncomingCallListener(
                  child: ResponsiveBuilder(child: child ?? const SizedBox.shrink()),
                ),
                ZegoUIKitPrebuiltCallMiniOverlayPage(
                  contextQuery: () => rootNavigatorKey.currentState?.context ?? context,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
