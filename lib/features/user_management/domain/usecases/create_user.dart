import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class CreateUser implements UseCase<User, CreateUserParams> {
  final UserRepository repository;

  CreateUser(this.repository);

  @override
  Future<Either<Failure, User>> call(CreateUserParams params) async {
    return await repository.createUser(params.user);
  }
}

class CreateUserParams {
  final User user;

  CreateUserParams({required this.user});
}

