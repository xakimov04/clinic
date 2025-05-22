import 'package:equatable/equatable.dart';

class AuthRequest extends Equatable {
  final String accessToken;
  final int vkId;
  final String firstName;
  final String lastName;

  const AuthRequest({
    required this.accessToken,
    required this.vkId,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [
        accessToken,
        vkId,
        firstName,
        lastName,
      ];
}
