import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class VerifyLogin implements UseCase<User, LoginParams> {
  final UserRepository repository;

  VerifyLogin(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.verifyLogin(params.username, params.password);
  }
}

class LoginParams {
  final String username;
  final String password;

  LoginParams({
    required this.username,
    required this.password,
  });
}

