import 'package:clinic/features/auth/domain/entities/send_otp_entity.dart';

class SendOtpModel extends SendOtpEntity {
  const SendOtpModel({
    required super.phoneNumber,
  });

  factory SendOtpModel.fromEntity(SendOtpEntity entity) {
    return SendOtpModel(
      phoneNumber: entity.phoneNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
    };
  }
}