import 'package:clinic/features/client/profile/domain/entities/profile_entities.dart';

class ProfileModel extends ProfileEntities {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatar,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
    };
  }
}
