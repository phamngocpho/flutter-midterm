part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUsersEvent extends UserEvent {}

class CreateUserEvent extends UserEvent {
  final User user;

  const CreateUserEvent(this.user);

  @override
  List<Object> get props => [user];
}

class UpdateUserEvent extends UserEvent {
  final User user;

  const UpdateUserEvent(this.user);

  @override
  List<Object> get props => [user];
}

class DeleteUserEvent extends UserEvent {
  final String username;

  const DeleteUserEvent(this.username);

  @override
  List<Object> get props => [username];
}

