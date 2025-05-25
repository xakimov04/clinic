import 'package:clinic/features/auth/domain/entities/doctor_login_response_entity.dart';

class DoctorLoginResponseModel extends DoctorLoginResponse {
  const DoctorLoginResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.detail,
    required super.userId,
    required super.userType,
  });

  factory DoctorLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return DoctorLoginResponseModel(
      detail: json['detail'] as String,
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
      userId: json['user_id'] as int,
      userType: json['user_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detail': detail,
      'access': accessToken,
      'refresh': refreshToken,
      'user_id': userId,
      'user_type': userType,
    };
  }
}
