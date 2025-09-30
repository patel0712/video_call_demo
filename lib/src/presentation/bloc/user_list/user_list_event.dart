part of 'user_list_bloc.dart';

abstract class UserListEvent {
  const UserListEvent();
}

class Initial extends UserListEvent {
  const Initial();
}

class GetUsersEvent extends UserListEvent {
  const GetUsersEvent();
}

class RefreshUsers extends UserListEvent {
  const RefreshUsers();
}

class LoadMoreUsers extends UserListEvent {
  const LoadMoreUsers();
}

