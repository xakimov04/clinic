import 'package:equatable/equatable.dart';

class DoctorLoginRequest extends Equatable {
  final String username;
  final String password;

  const DoctorLoginRequest({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}