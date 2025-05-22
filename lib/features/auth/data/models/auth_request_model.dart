import 'package:clinic/features/auth/domain/entities/auth_request_entities.dart';

class AuthRequestModel extends AuthRequest {
  const AuthRequestModel({
    required super.accessToken,
    required super.vkId,
    required super.firstName,
    required super.lastName,
  });

  factory AuthRequestModel.fromJson(Map<String, dynamic> json) {
    return AuthRequestModel(
      accessToken: json['access_token'],
      vkId: json['vk_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'vk_id': vkId,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}
