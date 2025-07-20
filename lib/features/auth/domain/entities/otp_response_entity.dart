class OtpResponseEntity {
  final String detail;
  final String access;
  final String refresh;
  final int userId;

  const OtpResponseEntity({
    required this.detail,
    required this.access,
    required this.refresh,
    required this.userId,
  });
}