import 'package:mongo_dart/mongo_dart.dart';

Future<void> main() async {
  print('=' * 60);
  print('MongoDB Connection Test');
  print('=' * 60);

  // Standard connection string cho MongoDB Atlas
  final uri = 'mongodb+srv://midterm:DkbcxDYZ7JoMYFqc@midterm.gxh5o95.mongodb.net/midterm?retryWrites=true&w=majority';
  Db? db;
  try {
    print('\nConnecting to MongoDB Atlas...');
    db = await Db.create(uri);
    await db.open();

    print('✓ SUCCESS: Connected to MongoDB!');
    print('  Database: ${db.databaseName}');

    // Test query
    final usersCollection = db.collection('users');
    final count = await usersCollection.count();
    print('  Users count: $count');

  } catch (e) {
    print('✗ ERROR: $e');
  } finally {
    if (db != null) {
      await db.close();
      print('\nConnection closed.');
    }
  }
}