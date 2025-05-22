class SendOtpEntity {
  final String phoneNumber;

  SendOtpEntity({
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
    };
  }

  factory SendOtpEntity.fromJson(Map<String, dynamic> json) {
    return SendOtpEntity(
      phoneNumber: json['phone_number'],
    );
  }
}
