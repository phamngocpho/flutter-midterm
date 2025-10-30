import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.username,
    required super.email,
    required super.password,
    super.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'password': password,
    };

    if (imageUrl != null) {
      data['imageUrl'] = imageUrl;
    }

    return data;
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      username: user.username,
      email: user.email,
      password: user.password,
      imageUrl: user.imageUrl,
    );
  }
}

