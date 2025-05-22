import 'package:clinic/features/auth/domain/entities/user_entities.dart';

class UserModel extends UserEntities {
  const UserModel(
      {required super.id,
      required super.name,
      required super.email,
      required super.image});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      image: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': image,
    };
  } 
}
