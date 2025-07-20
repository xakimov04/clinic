import 'package:equatable/equatable.dart';

class ProfileEntities extends Equatable {
  final int id;
  final String username;
  final String email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final bool verified;
  final bool agreedToTerms;
  final bool biometricEnabled;
  final String userType;
  final String firstName;
  final String lastName;
  final String middleName;
  final String? avatar;

  final String? specialization;
  final bool? isAvailable;
  final String? medicalLicense;

  const ProfileEntities({
    required this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    required this.verified,
    required this.agreedToTerms,
    required this.biometricEnabled,
    required this.userType,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    this.avatar,
    this.specialization,
    this.isAvailable,
    this.medicalLicense,
  });

  // Foydalanuvchi doctor ekanligini tekshirish
  bool get isDoctor => userType == 'doctor';

  // Foydalanuvchi patient ekanligini tekshirish
  bool get isPatient => userType == 'patient';

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        phoneNumber,
        dateOfBirth,
        gender,
        verified,
        agreedToTerms,
        biometricEnabled,
        userType,
        firstName,
        lastName,
        middleName,
        avatar,
        specialization,
        isAvailable,
        medicalLicense,
      ];
}
