import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility class for password hashing and verification
class PasswordHasher {
  /// Hash a password using SHA-256
  ///
  /// Takes a plain text password and returns its SHA-256 hash
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify if a plain text password matches a hashed password
  ///
  /// Returns true if the passwords match, false otherwise
  static bool verifyPassword(String plainPassword, String hashedPassword) {
    final hashedInput = hashPassword(plainPassword);
    return hashedInput == hashedPassword;
  }
}

