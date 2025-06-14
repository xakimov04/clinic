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
          ? _parseServerDate(json['date_of_birth'])
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
      name: entity.name,
      avatar: entity.avatar,
      fullName: entity.fullName,
      specialization: entity.specialization,
      isAvailable: entity.isAvailable,
      medicalLicense: entity.medicalLicense,
    );
  }

  /// Ma'lumotlarni yangilash uchun copyWith metodi
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
    String? name,
    String? avatar,
    String? fullName,
    String? specialization,
    bool? isAvailable,
    String? medicalLicense,
    // Null qiymatlarni o'rnatish uchun
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
      name: name ?? this.name,
      avatar: clearAvatar ? null : (avatar ?? this.avatar),
      fullName: fullName ?? this.fullName,
      specialization:
          clearSpecialization ? null : (specialization ?? this.specialization),
      isAvailable: isAvailable ?? this.isAvailable,
      medicalLicense:
          clearMedicalLicense ? null : (medicalLicense ?? this.medicalLicense),
    );
  }

  /// API ga yuborish uchun - ISO 8601 formatida
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'date_of_birth':
          dateOfBirth != null ? _isoDateFormat.format(dateOfBirth!) : null,
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

  /// Debug va logging uchun - full DateTime ma'lumoti bilan
  Map<String, dynamic> toJsonWithFullDate() {
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

  @override
  String toString() {
    return 'ProfileModel(id: $id, name: $name, email: $email, userType: $userType, dateOfBirth: ${isoFormattedDate})';
  }
}
