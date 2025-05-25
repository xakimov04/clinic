import 'package:clinic/features/auth/domain/entities/doctor_login_request_entity.dart';

class DoctorLoginRequestModel extends DoctorLoginRequest {
  const DoctorLoginRequestModel({
    required super.username,
    required super.password,
  });

  factory DoctorLoginRequestModel.fromJson(Map<String, dynamic> json) {
    return DoctorLoginRequestModel(
      username: json['username'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}