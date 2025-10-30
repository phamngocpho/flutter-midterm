import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String username;
  final String email;
  final String password;
  final String? imageUrl;

  const User({
    required this.username,
    required this.email,
    required this.password,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [username, email, password, imageUrl];

  User copyWith({
    String? username,
    String? email,
    String? password,
    String? imageUrl,
  }) {
    return User(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

