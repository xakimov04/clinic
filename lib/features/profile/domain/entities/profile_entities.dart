import 'package:equatable/equatable.dart';

class ProfileEntities extends Equatable {
  final int id;
  final String email;
  final String name;
  final String? avatar;

  const ProfileEntities({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, email, name, avatar];
}