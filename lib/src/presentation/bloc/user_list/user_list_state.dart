part of 'user_list_bloc.dart';

class UserListState {
  const UserListState({
    required this.state,
    required this.message,
    required this.users,
    required this.hasReachedMax,
    required this.isOffline,
    this.cachedUsers,
  });

  factory UserListState.initial() => const UserListState(
    state: RequestState.empty,
    message: '',
    users: [],
    cachedUsers: [],
    hasReachedMax: false,
    isOffline: false,
  );
  final RequestState state;
  final String message;
  final List<UserEntity> users;
  final List<UserEntity>? cachedUsers;
  final bool hasReachedMax;
  final bool isOffline;

  UserListState copyWith({
    RequestState? state,
    String? message,
    List<UserEntity>? users,
    bool? hasReachedMax,
    bool? isOffline,
    List<UserEntity>? cachedUsers,
  }) {
    return UserListState(
      state: state ?? this.state,
      message: message ?? this.message,
      users: users ?? this.users,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isOffline: isOffline ?? this.isOffline,
      cachedUsers: cachedUsers ?? this.cachedUsers,
    );
  }
}
