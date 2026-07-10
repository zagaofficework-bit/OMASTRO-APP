import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omastro/core/bloc/app_bloc_observer.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import 'package:omastro/core/theme/app_theme.dart';
import 'app/route.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/wallet/bloc/wallet_bloc.dart';
import 'features/profile/bloc/profile_bloc.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/astrologers/bloc/astrologers_bloc.dart';
import 'features/reviews/bloc/reviews_bloc.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // 1. Lock the screen on cold boot
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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
        BlocProvider(create: (_) => WalletBloc()),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => ChatBloc()),
        BlocProvider(create: (_) => AstrologersBloc()),
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
