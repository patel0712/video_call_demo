import 'package:bloc_clean_architecture/src/data/datasource/authentication_remote_data_source.dart';
import 'package:bloc_clean_architecture/src/data/datasource/user_local_data_source.dart';
import 'package:bloc_clean_architecture/src/data/datasource/user_remote_data_source.dart';
import 'package:bloc_clean_architecture/src/data/repository/authentication_repository_impl.dart';
import 'package:bloc_clean_architecture/src/data/repository/user_repository_impl.dart';
import 'package:bloc_clean_architecture/src/comman/api.dart';
import 'package:bloc_clean_architecture/src/domain/repositories/autentication_repository.dart';
import 'package:bloc_clean_architecture/src/domain/repositories/user_repository.dart';
import 'package:bloc_clean_architecture/src/domain/usecase/get_users.dart';
import 'package:bloc_clean_architecture/src/domain/usecase/login.dart';
import 'package:bloc_clean_architecture/src/presentation/bloc/authenticator_watcher/authenticator_watcher_bloc.dart';
import 'package:bloc_clean_architecture/src/presentation/bloc/sign_in_form/sign_in_form_bloc.dart';
import 'package:bloc_clean_architecture/src/presentation/bloc/user_list/user_list_bloc.dart';
import 'package:bloc_clean_architecture/src/presentation/bloc/video_call/video_call_bloc.dart';
import 'package:bloc_clean_architecture/src/presentation/cubit/theme/theme_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:bloc_clean_architecture/src/data/datasource/video_call_remote_data_source.dart';
import 'package:bloc_clean_architecture/src/data/repository/video_call_repository_impl.dart';
import 'package:bloc_clean_architecture/src/domain/repositories/video_call_repository.dart';
import 'package:bloc_clean_architecture/src/domain/usecase/video_call_usecases.dart';

final locator = GetIt.instance;

void init() {
  // External dependencies
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      // Do not throw for 4xx; we'll handle in code and surface proper errors
      validateStatus: (status) => status != null && status < 500,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
    ),
  );
  final connectivity = Connectivity();

  // Data sources
  final authRemoteDataSource = AuthenticationRemoteDataSourceImpl();
  locator.registerLazySingleton<AuthenticationRemoteDataSource>(
    () => authRemoteDataSource,
  );

  final userRemoteDataSource = UserRemoteDataSourceImpl(dio);
  locator.registerLazySingleton<UserRemoteDataSource>(
    () => userRemoteDataSource,
  );

  final userLocalDataSource = UserLocalDataSourceImpl();
  locator.registerLazySingleton<UserLocalDataSource>(() => userLocalDataSource);

  final videoCallRemote = ChimeVideoCallRemoteDataSource(dio);
  locator.registerLazySingleton<VideoCallRemoteDataSource>(
    () => videoCallRemote,
  );

  // Repositories
  final authRepository = AuthenticationRepositoryImpl(locator());
  locator.registerLazySingleton<AuthenticationRepository>(() => authRepository);

  final userRepository = UserRepositoryImpl(
    locator<UserRemoteDataSource>(),
    locator<UserLocalDataSource>(),
    connectivity,
  );
  locator.registerLazySingleton<UserRepository>(() => userRepository);

  final videoCallRepository = VideoCallRepositoryImpl(locator());
  locator.registerLazySingleton<VideoCallRepository>(() => videoCallRepository);

  // Use cases
  final signIn = SignIn(locator());
  locator.registerLazySingleton(() => signIn);

  final getUsers = GetUsers(locator<UserRepository>());
  locator.registerLazySingleton(() => getUsers);

  final initVideo = InitializeVideoCall(locator());
  final joinVideo = JoinMeeting(locator());
  final leaveVideo = LeaveMeeting(locator());
  final endVideo = EndMeeting(locator());
  final clearCache = ClearMeetingCache(locator());
  final toggleAudio = ToggleAudio(locator());
  final toggleVideo = ToggleVideo(locator());
  final toggleShare = ToggleScreenShare(locator());
  final getParticipantStates = GetParticipantStates(locator());
  locator.registerLazySingleton(() => initVideo);
  locator.registerLazySingleton(() => joinVideo);
  locator.registerLazySingleton(() => leaveVideo);
  locator.registerLazySingleton(() => endVideo);
  locator.registerLazySingleton(() => clearCache);
  locator.registerLazySingleton(() => toggleAudio);
  locator.registerLazySingleton(() => toggleVideo);
  locator.registerLazySingleton(() => toggleShare);
  locator.registerLazySingleton(() => getParticipantStates);

  // BLoCs
  final authenticatorWatcherBloc = AuthenticatorWatcherBloc();
  locator.registerLazySingleton(() => authenticatorWatcherBloc);

  final signInFormBloc = SignInFormBloc(locator());
  locator.registerLazySingleton(() => signInFormBloc);

  final userListBloc = UserListBloc(locator());
  locator.registerLazySingleton(() => userListBloc);

  final videoCallBloc = VideoCallBloc(
    locator<InitializeVideoCall>(),
    locator<JoinMeeting>(),
    locator<LeaveMeeting>(),
    locator<EndMeeting>(),
    locator<ClearMeetingCache>(),
    locator<ToggleAudio>(),
    locator<ToggleVideo>(),
    locator<ToggleScreenShare>(),
    locator<GetParticipantStates>(),
  );
  locator.registerLazySingleton(() => videoCallBloc);

  final themeCubit = ThemeCubit();
  locator.registerLazySingleton(() => themeCubit);
}
