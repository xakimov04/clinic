// lib/features/profile/data/model/profile_model.dart
import 'package:clinic/features/profile/domain/entities/profile_entities.dart';
import 'profile_update_request.dart';
import 'package:intl/intl.dart';

class ProfileModel extends ProfileEntities {
  // ISO 8601 date format uchun static formatter
  static final DateFormat _isoDateFormat = DateFormat('yyyy-MM-dd');

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
    super.avatar,
    super.specialization,
    super.isAvailable,
    super.medicalLicense,
    required super.firstName,
    required super.lastName,
    required super.middleName,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    String getValidString(dynamic value, [String fallback = "Не указано"]) {
      if (value == null || (value is String && value.trim().isEmpty)) {
        return fallback;
      }
      return value.toString();
    }

    return ProfileModel(
      id: json['id'],
      username: getValidString(json['username']),
      email: getValidString(json['email']),
      phoneNumber: getValidString(json['phone_number'], ''),
      dateOfBirth: json['date_of_birth'] != null
          ? _parseServerDate(json['date_of_birth'])
          : null,
      gender: getValidString(json['gender'], ''),
      verified: json['verified'] ?? false,
      agreedToTerms: json['agreed_to_terms'] ?? false,
      biometricEnabled: json['biometric_enabled'] ?? false,
      userType: getValidString(json['user_type']),
      firstName: json['first_name'] ?? "",
      lastName: json['last_name'] ?? "",
      middleName: json['middle_name'] ?? "",
      avatar: getValidString(json['avatar'], ''),
      specialization: getValidString(json['specialization'], "Не указано"),
      isAvailable: json['is_available'],
      medicalLicense: getValidString(json['medical_license'], "Не указано"),
    );
  }

  /// Server formatini DateTime ga parse qilish
  /// Supports: "2000-06-21 00:00:00.000", "2000-06-21T00:00:00.000Z", "2000-06-21"
  static DateTime? _parseServerDate(dynamic dateValue) {
    if (dateValue == null) return null;

    try {
      if (dateValue is DateTime) return dateValue;

      String dateString = dateValue.toString();

      // Milliseconds va timezone info ni olib tashlash
      String cleanDate = dateString
          .replaceAll('.000', '')
          .replaceAll('T', ' ')
          .replaceAll('Z', '')
          .trim();

      // Agar faqat sana bo'lsa (yyyy-MM-dd)
      if (cleanDate.length == 10) {
        return DateTime.parse(cleanDate);
      }

      // Agar sana va vaqt bo'lsa (yyyy-MM-dd HH:mm:ss)
      return DateTime.parse(cleanDate);
    } catch (e) {
      // Fallback - try standard DateTime.parse
      try {
        return DateTime.parse(dateValue.toString());
      } catch (_) {
        return null;
      }
    }
  }

  /// Entity dan Model yaratish uchun factory
  factory ProfileModel.fromEntity(ProfileEntities entity) {
    return ProfileModel(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      verified: entity.verified,
      agreedToTerms: entity.agreedToTerms,
      biometricEnabled: entity.biometricEnabled,
      userType: entity.userType,
      avatar: entity.avatar,
      specialization: entity.specialization,
      isAvailable: entity.isAvailable,
      medicalLicense: entity.medicalLicense,
      firstName: entity.firstName,
      lastName: entity.lastName,
      middleName: entity.middleName,
    );
  }

  ProfileModel copyWith({
    int? id,
    String? username,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    bool? verified,
    bool? agreedToTerms,
    bool? biometricEnabled,
    String? userType,
    String? firstName,
    String? lastName,
    String? middleName,
    String? avatar,
    String? fullName,
    String? specialization,
    bool? isAvailable,
    String? medicalLicense,
    bool clearPhoneNumber = false,
    bool clearDateOfBirth = false,
    bool clearGender = false,
    bool clearAvatar = false,
    bool clearSpecialization = false,
    bool clearMedicalLicense = false,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      gender: clearGender ? null : (gender ?? this.gender),
      verified: verified ?? this.verified,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      userType: userType ?? this.userType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      avatar: clearAvatar ? null : (avatar ?? this.avatar),
      specialization:
          clearSpecialization ? null : (specialization ?? this.specialization),
      isAvailable: isAvailable ?? this.isAvailable,
      medicalLicense:
          clearMedicalLicense ? null : (medicalLicense ?? this.medicalLicense),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'date_of_birth':
          dateOfBirth != null ? _isoDateFormat.format(dateOfBirth!) : null,
      'gender': gender,
      'agreed_to_terms': agreedToTerms,
      'biometric_enabled': biometricEnabled,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'specialization': specialization,
      'is_available': isAvailable,
      'medical_license': medicalLicense,
    };
  }

  /// Update uchun ProfileUpdateRequest yaratish
  static ProfileUpdateRequest createUpdateRequest({
    required ProfileEntities original,
    required ProfileEntities updated,
  }) {
    return ProfileUpdateRequest(
      originalProfile: original,
      updatedProfile: updated,
    );
  }

  /// Date formatlarini tekshirish uchun getter
  String? get isoFormattedDate {
    return dateOfBirth != null ? _isoDateFormat.format(dateOfBirth!) : null;
  }
}
