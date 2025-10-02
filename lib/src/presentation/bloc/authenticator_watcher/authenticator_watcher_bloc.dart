import 'package:bloc_clean_architecture/src/comman/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'authenticator_watcher_event.dart';
part 'authenticator_watcher_state.dart';
part 'authenticator_watcher_bloc.freezed.dart';

class AuthenticatorWatcherBloc
    extends Bloc<AuthenticatorWatcherEvent, AuthenticatorWatcherState> {
  AuthenticatorWatcherBloc()
      : super(const AuthenticatorWatcherState.initial()) {
    on<AuthenticatorWatcherEvent>((event, emit) async {
      await event.map(
        authCheckRequest: (_) async {
          try {
            emit(const AuthenticatorWatcherState.authenticating());
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString(ACCESS_TOKEN);
            final showOnboarding = prefs.getString(ONBOARDING);

            if (showOnboarding == null) {
              // First time user - set onboarding flag and navigate to login
              await prefs.setString(ONBOARDING, ONBOARDING);
              emit(const AuthenticatorWatcherState.isFirstTime());
            } else if (token != null && token.isNotEmpty) {
              // User has valid token - navigate to dashboard
              emit(const AuthenticatorWatcherState.authenticated());
            } else {
              // User has no valid token - navigate to login
              emit(const AuthenticatorWatcherState.unauthenticated());
            }
          } catch (e) {
            // If there's any error, default to unauthenticated
            emit(const AuthenticatorWatcherState.unauthenticated());
          }
        },
        signOut: (_) async {
          emit(const AuthenticatorWatcherState.authenticating());
          final prefs = await SharedPreferences.getInstance();
          prefs.remove(ACCESS_TOKEN);
          emit(const AuthenticatorWatcherState.unauthenticated());
        },
      );
    });
  }
}
