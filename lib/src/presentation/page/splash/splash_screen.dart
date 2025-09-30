import 'package:bloc_clean_architecture/src/comman/routes.dart';
import 'package:bloc_clean_architecture/src/presentation/bloc/authenticator_watcher/authenticator_watcher_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () {
      Future.microtask(
        () => context.read<AuthenticatorWatcherBloc>().add(
          const AuthenticatorWatcherEvent.authCheckRequest(),
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticatorWatcherBloc, AuthenticatorWatcherState>(
      listener: (context, state) {
        state.maybeMap(
          orElse: () {},
          authenticating: (_) {},
          authenticated: (_) {
            context.replaceNamed(AppRoutes.DASHBOARD_ROUTE_NAME);
          },
          isFirstTime: (_) {},
          unauthenticated: (_) {
            context.replaceNamed(AppRoutes.LOGIN_ROUTE_NAME);
          },
        );
      },
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha:0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.videocam, size: 60, color: Colors.blue),
              ),
              const SizedBox(height: 30),

              // App Name
              Text(
                'VideoCall',
                style: GoogleFonts.pacifico(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // App Tagline
              Text(
                'Connect with the world',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha:0.9),
                ),
              ),
              const SizedBox(height: 50),

              // Loading indicator
              SpinKitFadingCircle(color: Colors.white, size: 30.0),
              const SizedBox(height: 20),

              // Loading text
              Text(
                'Loading...',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha:0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
