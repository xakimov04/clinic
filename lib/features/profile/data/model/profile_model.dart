import 'package:clinic/features/profile/domain/entities/profile_entities.dart';

class ProfileModel extends ProfileEntities {
  const ProfileModel({
    required super.id,
    required super.username,
    required super.email,
    super.phoneNumber,
    super.dateOfBirth,
    super.gender,
    required super.verified,
    required super.agreedToTerms,
    required super.biometricEnabled,
    required super.userType,
    required super.name,
    super.avatar,
    required super.fullName,
    super.specialization,
    super.isAvailable,
    super.medicalLicense,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      gender: json['gender'],
      verified: json['verified'] ?? false,
      agreedToTerms: json['agreed_to_terms'] ?? false,
      biometricEnabled: json['biometric_enabled'] ?? false,
      userType: json['user_type'],
      name: json['name'],
      avatar: json['avatar'],
      fullName: json['full_name'],
      specialization: json['specialization'],
      isAvailable: json['is_available'],
      medicalLicense: json['medical_license'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'verified': verified,
      'agreed_to_terms': agreedToTerms,
      'biometric_enabled': biometricEnabled,
      'user_type': userType,
      'name': name,
      'avatar': avatar,
      'full_name': fullName,
      'specialization': specialization,
      'is_available': isAvailable,
      'medical_license': medicalLicense,
    };
  }
}
