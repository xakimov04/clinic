import 'package:clinic/features/auth/data/models/user_model.dart';
import 'package:clinic/features/auth/domain/entities/auth_response_entity.dart';

class AuthResponseModel extends AuthResponseEntity {
  const AuthResponseModel(
      {required super.accessToken,
      required super.refreshToken,
      required super.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access'],
      refreshToken: json['refresh'],
      user: UserModel.fromJson(json['user']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'refresh': refreshToken,
      'user': (user as UserModel).toJson(),
    };
  }
}
