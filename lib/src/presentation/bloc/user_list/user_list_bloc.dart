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
      await _loadUsers(emit);
    });

    on<RefreshUsers>((event, emit) async {
      emit(state.copyWith(state: RequestState.loading));
      await _loadUsers(emit);
    });
  }

  final GetUsers _getUsers;

  Future<void> _loadUsers(Emitter<UserListState> emit) async {
    final result =
        await _getUsers.call(1); // Always use page 1 since no pagination

    result.fold(
      (Failure failure) {
        emit(
          state.copyWith(
            state: RequestState.error,
            message: failure.message,
          ),
        );
        print("Error =============> $failure");
      },
      (List<UserEntity> users) {
        emit(
          state.copyWith(
            state: RequestState.loaded,
            users: users,
            message: '',
          ),
        );
      },
    );
  }
}
