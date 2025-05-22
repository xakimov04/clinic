import 'package:clinic/features/auth/domain/entities/user_entities.dart';
import 'package:equatable/equatable.dart';

class AuthResponseEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserEntities user;

  const AuthResponseEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
