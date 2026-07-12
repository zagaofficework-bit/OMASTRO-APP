import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omastro/core/bloc/app_bloc_observer.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import 'package:omastro/core/theme/app_theme.dart';
import 'app/route.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/wallet/bloc/wallet_bloc.dart';
import 'features/wallet/bloc/wallet_event.dart';
import 'features/profile/bloc/profile_bloc.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/astrologers/bloc/astrologers_bloc.dart';
import 'features/astrologers/bloc/astrologers_event.dart';
import 'features/reviews/bloc/reviews_bloc.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // 1. Lock the screen on cold boot
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize dotenv and Supabase
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Google Sign-In with Web Client ID for Supabase validation
  await google_sign_in.GoogleSignIn.instance.initialize(
    clientId: dotenv.env['GOOGLE_WEB_CLIENT_ID']!,
    serverClientId: kIsWeb ? null : dotenv.env['GOOGLE_WEB_CLIENT_ID']!,
  );

  // Initialize the global BlocObserver for tracking state changes
  Bloc.observer = AppBlocObserver();

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
  }

  void removeSplash() async {
    // A tiny delay gives the UI thread a breathing room frame to complete setup
    await Future.delayed(Duration.zero);
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => WalletBloc()..add(LoadWallet())),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => ChatBloc()),
        BlocProvider(create: (_) => AstrologersBloc()..add(LoadAstrologers())),
        BlocProvider(create: (_) => ReviewsBloc()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        builder: (context, child) {
          return ResponsiveBuilder(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}
