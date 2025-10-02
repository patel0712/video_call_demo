part of 'user_list_bloc.dart';

class UserListState {
  const UserListState({
    required this.state,
    required this.message,
    required this.users,
  });

  factory UserListState.initial() => const UserListState(
        state: RequestState.empty,
        message: '',
        users: [],
      );

  final RequestState state;
  final String message;
  final List<UserEntity> users;

  UserListState copyWith({
    RequestState? state,
    String? message,
    List<UserEntity>? users,
  }) {
    return UserListState(
      state: state ?? this.state,
      message: message ?? this.message,
      users: users ?? this.users,
    );
  }
}
