import 'package:clinic/features/auth/domain/entities/otp_response_entity.dart';

class OtpResponseModel extends OtpResponseEntity {
  const OtpResponseModel({
    required super.detail,
    required super.token,
    required super.userId,
    required super.userType,
    required super.isNewUser,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      detail: json['detail'] ?? '',
      token: json['token'] ?? '',
      userId: json['user_id'] ?? 0,
      userType: json['user_type'] ?? '',
      isNewUser: json['is_new_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detail': detail,
      'token': token,
      'user_id': userId,
      'user_type': userType,
      'is_new_user': isNewUser,
    };
  }
}
