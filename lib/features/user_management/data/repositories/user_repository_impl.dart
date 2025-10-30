import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      final users = await remoteDataSource.getAllUsers();
      return Right(users.map((user) => UserModel.fromJson(user)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserByUsername(String username) async {
    try {
      final user = await remoteDataSource.getUserByUsername(username);
      return Right(UserModel.fromJson(user));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> createUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final createdUser = await remoteDataSource.createUser(userModel.toJson());
      return Right(UserModel.fromJson(createdUser));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final updatedUser = await remoteDataSource.updateUser(
        user.username,
        userModel.toJson(),
      );
      return Right(UserModel.fromJson(updatedUser));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String username) async {
    try {
      await remoteDataSource.deleteUser(username);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

