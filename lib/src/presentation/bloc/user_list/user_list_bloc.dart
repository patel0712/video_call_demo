import 'package:bloc_clean_architecture/src/comman/enum.dart';
import 'package:bloc_clean_architecture/src/comman/failure.dart';
import 'package:bloc_clean_architecture/src/domain/entities/user_entity.dart';
import 'package:bloc_clean_architecture/src/domain/usecase/get_users.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  UserListBloc(this._getUsers) : super(UserListState.initial()) {
    on<Initial>((event, emit) {
      emit(UserListState.initial());
    });

    on<GetUsersEvent>((event, emit) async {
      if (state.state == RequestState.loaded) {
        return; // Prevent multiple loads
      }
      emit(state.copyWith(state: RequestState.loading));
      await _loadUsers(emit, isRefresh: false);
    });

    on<RefreshUsers>((event, emit) async {
      _currentPage = 1;
      _allUsers = [];
      _hasReachedMax = false;
      emit(state.copyWith(state: RequestState.loading));
      await _loadUsers(emit, isRefresh: true);
    });

    on<LoadMoreUsers>((event, emit) async {
      if (_hasReachedMax) return;
      if (state.state == RequestState.loaded && state.users.isNotEmpty) {
        _currentPage++;
        await _loadUsers(emit, isRefresh: false);
      }
    });
  }

  final GetUsers _getUsers;
  int _currentPage = 1;
  List<UserEntity> _allUsers = [];
  bool _hasReachedMax = false;

  Future<void> _loadUsers(
    Emitter<UserListState> emit, {
    required bool isRefresh,
  }) async {
    final result = await _getUsers.call(_currentPage);

    result.fold(
      (Failure failure) {
        if (isRefresh) {
          emit(
            state.copyWith(state: RequestState.error, message: failure.message),
          );
        } else {
          // Keep existing users if available
          emit(
            state.copyWith(
              state: RequestState.error,
              message: failure.message,
              cachedUsers: _allUsers.isNotEmpty ? _allUsers : null,
            ),
          );
        }
        print("Error =============> $failure");
      },
      (List<UserEntity> users) {
        if (isRefresh) {
          _allUsers = List<UserEntity>.from(users);
        } else {
          _allUsers.addAll(users);
        }

        // Check if we've reached the maximum (assuming 10 users per page)
        _hasReachedMax = users.length < 10;

        // Check if we're offline by seeing if we got cached data
        final isOffline = users.isNotEmpty && _allUsers.length <= users.length;

        emit(
          state.copyWith(
            state: RequestState.loaded,
            users: _allUsers,
            hasReachedMax: _hasReachedMax,
            isOffline: isOffline,
            message: '',
          ),
        );
      },
    );
  }
}
