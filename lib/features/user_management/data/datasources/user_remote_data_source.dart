import 'package:mongo_dart/mongo_dart.dart';

abstract class UserRemoteDataSource {
  Future<List<Map<String, dynamic>>> getAllUsers();
  Future<Map<String, dynamic>> getUserByUsername(String username);
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> user);
  Future<Map<String, dynamic>> updateUser(String username, Map<String, dynamic> user);
  Future<void> deleteUser(String username);
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

      final result = await _collection.insertOne(user);
      if (result.isSuccess) {
        user.remove('_id');
        return user;
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
      final result = await _collection.replaceOne(
        where.eq('username', username),
        user,
      );

      if (result.isSuccess && result.nModified > 0) {
        user.remove('_id');
        return user;
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
}

