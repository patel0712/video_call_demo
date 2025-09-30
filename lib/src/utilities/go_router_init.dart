import 'package:bloc_clean_architecture/src/comman/routes.dart';
import 'package:bloc_clean_architecture/src/presentation/page/auth/sign_in_screen.dart';
import 'package:bloc_clean_architecture/src/presentation/page/auth/sign_up_screen.dart';
import 'package:bloc_clean_architecture/src/presentation/page/dashboard/dashboard_screen.dart';
import 'package:bloc_clean_architecture/src/presentation/page/error/error_screen.dart';
import 'package:bloc_clean_architecture/src/presentation/page/splash/splash_screen.dart';
import 'package:bloc_clean_architecture/src/presentation/page/user_list/user_list_screen.dart';
import 'package:bloc_clean_architecture/src/presentation/page/video_call/video_call_screen.dart';
import 'package:bloc_clean_architecture/src/presentation/page/video_call/video_call_debug_screen.dart';
import 'package:bloc_clean_architecture/src/utilities/logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter routerinit = GoRouter(
  routes: <RouteBase>[
    ///  =================================================================
    ///  ********************** Splash Route *****************************
    /// ==================================================================
    GoRoute(
      name: AppRoutes.SPLASH_ROUTE_NAME,
      path: AppRoutes.SPLASH_ROUTE_PATH,
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),

    ///  =================================================================
    /// ********************** Authentication Routes ********************
    /// ==================================================================
    GoRoute(
      name: AppRoutes.LOGIN_ROUTE_NAME,
      path: AppRoutes.LOGIN_ROUTE_PATH,
      builder: (BuildContext context, GoRouterState state) {
        return const SignInPage();
      },
    ),
    GoRoute(
      name: AppRoutes.SIGNUP_ROUTE_NAME,
      path: AppRoutes.SIGNUP_ROUTE_PATH,
      builder: (BuildContext context, GoRouterState state) {
        return const SignUnPage();
      },
    ),

    ///  =================================================================
    /// ********************** DashBoard Route ******************************
    /// ==================================================================
    GoRoute(
      name: AppRoutes.DASHBOARD_ROUTE_NAME,
      path: AppRoutes.DASHBOARD_ROUTE_PATH,
      builder: (BuildContext context, GoRouterState state) {
        return const DashBoardScreen();
      },
    ),

    ///  =================================================================
    /// ********************** User List Route ******************************
    /// ==================================================================
    GoRoute(
      name: AppRoutes.USER_LIST_ROUTE_NAME,
      path: AppRoutes.USER_LIST_ROUTE_PATH,
      builder: (BuildContext context, GoRouterState state) {
        return const UserListScreen();
      },
    ),

    ///  =================================================================
    /// ********************** Video Call Route ******************************
    /// ==================================================================
    GoRoute(
      name: AppRoutes.VIDEO_CALL_ROUTE_NAME,
      path: AppRoutes.VIDEO_CALL_ROUTE_PATH,
      builder: (BuildContext context, GoRouterState state) {
        final meetingId = state.uri.queryParameters['meetingId'];
        final participantName = state.uri.queryParameters['participantName'];
        return VideoCallScreen(
          meetingId: meetingId,
          participantName: participantName,
        );
      },
    ),

    ///  =================================================================
    /// ********************** Video Call Debug Route ******************************
    /// ==================================================================
    GoRoute(
      name: 'video_call_debug',
      path: '/video-call-debug',
      builder: (BuildContext context, GoRouterState state) {
        return const VideoCallDebugScreen();
      },
    ),
  ],
  errorPageBuilder: (context, state) {
    return const MaterialPage(child: ErrorScreen());
  },
  redirect: (context, state) {
    logger.info('redirect: ${state.uri}');
    return null;
  },
);
