import 'package:equatable/equatable.dart';

class DoctorLoginResponse extends Equatable {
  final String detail;
  final String accessToken;
  final String refreshToken;
  final int userId;
  final String userType;

  const DoctorLoginResponse({
    required this.detail,
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.userType,
  });

  @override
  List<Object?> get props => [
        detail,
        accessToken,
        refreshToken,
        userId,
        userType,
      ];
}
