import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/create_user.dart';
import '../../domain/usecases/delete_user.dart';
import '../../domain/usecases/get_all_users.dart';
import '../../domain/usecases/update_user.dart';
import '../../../../core/usecases/usecase.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetAllUsers getAllUsers;
  final CreateUser createUser;
  final UpdateUser updateUser;
  final DeleteUser deleteUser;

  UserBloc({
    required this.getAllUsers,
    required this.createUser,
    required this.updateUser,
    required this.deleteUser,
  }) : super(UserInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await getAllUsers(NoParams());

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (users) => emit(UsersLoaded(users)),
    );
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await createUser(CreateUserParams(user: event.user));

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) {
        // Reload users after creation
        add(LoadUsersEvent());
      },
    );
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await updateUser(UpdateUserParams(user: event.user));

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) {
        // Reload users after update
        add(LoadUsersEvent());
      },
    );
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await deleteUser(DeleteUserParams(username: event.username));

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (_) {
        // Reload users after deletion
        add(LoadUsersEvent());
      },
    );
  }
}

