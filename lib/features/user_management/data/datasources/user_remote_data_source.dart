import 'package:mongo_dart/mongo_dart.dart';
import '../../../../core/utils/password_hasher.dart';

abstract class UserRemoteDataSource {
  Future<List<Map<String, dynamic>>> getAllUsers();
  Future<Map<String, dynamic>> getUserByUsername(String username);
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> user);
  Future<Map<String, dynamic>> updateUser(String username, Map<String, dynamic> user);
  Future<void> deleteUser(String username);
  Future<Map<String, dynamic>> verifyLogin(String username, String password);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Db database;
  final String collectionName;

  UserRemoteDataSourceImpl({
    required this.database,
    required this.collectionName,
  });

  DbCollection get _collection {
    if (!database.isConnected) {
      throw Exception('Database is not connected. State: ${database.state}');
    }
    return database.collection(collectionName);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final users = await _collection.find().toList();
      // Remove _id field from results since we don't use it
      return users.map((user) {
        user.remove('_id');
        return user;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserByUsername(String username) async {
    try {
      final user = await _collection.findOne(where.eq('username', username));
      if (user == null) {
        throw Exception('User not found');
      }
      user.remove('_id');
      return user;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> user) async {
    try {
      // Check if username already exists
      final existingUser = await _collection.findOne(where.eq('username', user['username']));
      if (existingUser != null) {
        throw Exception('Username already exists');
      }

      // Hash the password before storing
      final userWithHashedPassword = Map<String, dynamic>.from(user);
      if (userWithHashedPassword.containsKey('password')) {
        userWithHashedPassword['password'] = PasswordHasher.hashPassword(user['password']);
      }

      final result = await _collection.insertOne(userWithHashedPassword);
      if (result.isSuccess) {
        userWithHashedPassword.remove('_id');
        return userWithHashedPassword;
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateUser(String username, Map<String, dynamic> user) async {
    try {
      // Hash the password if it's being updated
      final userWithHashedPassword = Map<String, dynamic>.from(user);
      if (userWithHashedPassword.containsKey('password') && userWithHashedPassword['password'].isNotEmpty) {
        userWithHashedPassword['password'] = PasswordHasher.hashPassword(user['password']);
      }

      final result = await _collection.replaceOne(
        where.eq('username', username),
        userWithHashedPassword,
      );

      if (result.isSuccess && result.nModified > 0) {
        userWithHashedPassword.remove('_id');
        return userWithHashedPassword;
      } else {
        throw Exception('User not found or no changes made');
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String username) async {
    try {
      final result = await _collection.deleteOne(where.eq('username', username));

      if (!result.isSuccess || result.nRemoved == 0) {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyLogin(String username, String password) async {
    try {
      // Try to find user by email first, then by username (for backward compatibility)
      var user = await _collection.findOne(where.eq('email', username));

      user ??= await _collection.findOne(where.eq('username', username));

      if (user == null) {
        throw Exception('Invalid email/username or password');
      }

      final storedPassword = user['password'] as String;

      // Check if password matches (support both hashed and plain text for backward compatibility)
      final isPasswordValid = storedPassword == password || // Plain text (old data)
                              PasswordHasher.verifyPassword(password, storedPassword); // Hashed (new data)

      if (!isPasswordValid) {
        throw Exception('Invalid email/username or password');
      }

      // If password was plain text, update it to hashed version
      if (storedPassword == password) {
        try {
          final hashedPassword = PasswordHasher.hashPassword(password);
          await _collection.updateOne(
            where.eq('username', user['username']),
            modify.set('password', hashedPassword),
          );
          user['password'] = hashedPassword;
        } catch (e) {
          // Log error but don't fail login
          print('Warning: Failed to update password hash: $e');
        }
      }

      user.remove('_id');
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}

