import 'package:mongo_dart/mongo_dart.dart';
import '../constants/app_constants.dart';
import '../utils/password_hasher.dart';

/// Seed admin account to database if not exists
Future<void> seedAdminAccount(Db db) async {
  try {
    final collection = db.collection(AppConstants.usersCollection);

    // Check if admin already exists
    final existingAdmin = await collection.findOne(where.eq('email', 'admin@gmail.com'));

    if (existingAdmin == null) {
      print('Creating default admin account...');

      // Create admin account
      final adminUser = {
        'username': 'admin',
        'email': 'admin@gmail.com',
        'password': PasswordHasher.hashPassword('admin'),
        'imageUrl': null,
      };

      final result = await collection.insertOne(adminUser);

      if (result.isSuccess) {
        print('Admin account created successfully!');
        print('   Email: admin@gmail.com');
        print('   Password: admin');
      } else {
        print('Failed to create admin account');
      }
    } else {
      print('Admin account already exists');
    }
  } catch (e) {
    print('Error seeding admin account: $e');
  }
}

