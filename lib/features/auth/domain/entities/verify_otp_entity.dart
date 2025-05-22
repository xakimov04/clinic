class VerifyOtpEntity {
  final String phoneNumber;
  final String otp;

  VerifyOtpEntity({
    required this.phoneNumber,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'otp': otp,
    };
  }

  factory VerifyOtpEntity.fromJson(Map<String, dynamic> json) {
    return VerifyOtpEntity(
      phoneNumber: json['phone_number'],
      otp: json['otp'],
    );
  }
}
