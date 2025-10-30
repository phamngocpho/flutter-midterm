import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // MongoDB Configuration
  static String get databaseName => dotenv.env['MONGODB_DATABASE_NAME'] ?? 'midterm';
  static String get mongoDbBaseUrl => dotenv.env['MONGODB_BASE_URL'] ?? '';
  static String get mongoDbOptions => dotenv.env['MONGODB_OPTIONS'] ?? 'retryWrites=true&w=majority';
  static String get mongoDbUrl => '$mongoDbBaseUrl/$databaseName?$mongoDbOptions';
  static String get usersCollection => dotenv.env['MONGODB_USERS_COLLECTION'] ?? 'users';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxUsernameLength = 50;
}
