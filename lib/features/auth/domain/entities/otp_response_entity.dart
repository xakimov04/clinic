class OtpResponseEntity {
  final String detail;
  final String token;
  final int userId;
  final String userType;
  final bool isNewUser;

  const OtpResponseEntity({
    required this.detail,
    required this.token,
    required this.userId,
    required this.userType,
    required this.isNewUser,
  });
}