import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  static User userFromJson(String str) => User.fromJson(json.decode(str));

  static String userToJson(User data) => json.encode(data.toJson());

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
