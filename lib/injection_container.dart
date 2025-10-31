import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'core/constants/app_constants.dart';
import 'features/user_management/data/datasources/user_remote_data_source.dart';
import 'features/user_management/data/repositories/user_repository_impl.dart';
import 'features/user_management/domain/repositories/user_repository.dart';
import 'features/user_management/domain/usecases/create_user.dart';
import 'features/user_management/domain/usecases/delete_user.dart';
import 'features/user_management/domain/usecases/get_all_users.dart';
import 'features/user_management/domain/usecases/update_user.dart';
import 'features/user_management/domain/usecases/verify_login.dart';
import 'features/user_management/presentation/bloc/user_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(
    () => UserBloc(
      getAllUsers: sl(),
      createUser: sl(),
      updateUser: sl(),
      verifyLogin: sl(),
      deleteUser: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllUsers(sl()));
  sl.registerLazySingleton(() => CreateUser(sl()));
  sl.registerLazySingleton(() => UpdateUser(sl()));
  sl.registerLazySingleton(() => VerifyLogin(sl()));
  sl.registerLazySingleton(() => DeleteUser(sl()));

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(
      database: sl(),
      collectionName: AppConstants.usersCollection,
    ),
  );

  // External - Connect to MongoDB (throws error if failed)
  final db = await _initDatabase();
  sl.registerLazySingleton<Db>(() => db);
}

Future<Db> _initDatabase() async {
  Db? db;
  try {
    // Create database connection with timeout
    db = await Db.create(AppConstants.mongoDbUrl);

    // Open connection with timeout handling
    await db.open().timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        db?.close();
        throw TimeoutException(
          'Connection timeout: Could not connect to MongoDB within 20 seconds. '
          'If using Android emulator, try: 1) Restart emulator, '
          '2) Check emulator internet connection, 3) Verify mongodb+srv DNS resolution.',
          const Duration(seconds: 20),
        );
      },
    );

    // Verify connection
    if (!db.isConnected) {
      await db.close();
      throw Exception('Database is not connected. State: ${db.state}');
    }

    // Test connection with a simple ping (with timeout)
    await db.collection(AppConstants.usersCollection)
        .count()
        .timeout(const Duration(seconds: 5));

    // Only print success message when there's no error
    print('Connected to MongoDB successfully');
    print('   Database: ${db.databaseName}');
    print('   State: ${db.state}');

    return db;
  } catch (e) {
    // Clean up if db was created but failed to connect
    if (db != null && (db.isConnected || db.state == State.opening)) {
      try {
        await db.close();
      } catch (_) {
        // Ignore cleanup errors
      }
    }

    // Don't print error messages, just rethrow with better context
    if (e is TimeoutException) {
      rethrow;
    }
    // Wrap other exceptions to provide better error context
    throw Exception(
      'MongoDB connection failed: ${e.toString()}. '
      'Make sure you have internet connection and MongoDB Atlas allows connections from your IP address.',
    );
  }
}



