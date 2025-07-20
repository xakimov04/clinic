import 'package:clinic/features/auth/domain/entities/otp_response_entity.dart';

class OtpResponseModel extends OtpResponseEntity {
  const OtpResponseModel({
    required super.detail,
    required super.access,
    required super.userId,
    required super.refresh,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      detail: json['detail'] ?? '',
      access: json['access'] ?? '',
      userId: json['user_id'] ?? 0,
      refresh: json['refresh'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detail': detail,
      'access': access,
      'user_id': userId,
      'refresh': refresh,
    };
  }
}
