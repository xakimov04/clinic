import 'package:clinic/features/auth/domain/entities/verify_otp_entity.dart';

class VerifyOtpModel extends VerifyOtpEntity {
  const VerifyOtpModel({
    required super.phoneNumber,
    required super.otp,
  });

  factory VerifyOtpModel.fromEntity(VerifyOtpEntity entity) {
    return VerifyOtpModel(
      phoneNumber: entity.phoneNumber,
      otp: entity.otp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'otp': otp,
    };
  }
}
