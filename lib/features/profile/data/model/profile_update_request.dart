// lib/features/profile/data/model/profile_update_request.dart
import 'package:clinic/features/profile/domain/entities/profile_entities.dart';

/// Faqat o'zgargan maydonlarni track qiladigan class
class ProfileUpdateRequest {
  final Map<String, dynamic> _changedFields = {};
  final ProfileEntities originalProfile;
  final ProfileEntities updatedProfile;

  ProfileUpdateRequest({
    required this.originalProfile,
    required this.updatedProfile,
  }) {
    _trackChanges();
  }

  /// O'zgarishlarni aniqlash va track qilish
  void _trackChanges() {
    // Name
    if (originalProfile.name != updatedProfile.name) {
      _changedFields['name'] = updatedProfile.name;
    }

    // Full name
    if (originalProfile.fullName != updatedProfile.fullName) {
      _changedFields['full_name'] = updatedProfile.fullName;
    }

    // Phone number
    if (originalProfile.phoneNumber != updatedProfile.phoneNumber) {
      if (updatedProfile.phoneNumber != null && updatedProfile.phoneNumber!.isNotEmpty) {
        _changedFields['phone_number'] = updatedProfile.phoneNumber;
      } else {
        _changedFields['phone_number'] = null;
      }
    }

    // Date of birth
    if (originalProfile.dateOfBirth != updatedProfile.dateOfBirth) {
      if (updatedProfile.dateOfBirth != null) {
        _changedFields['date_of_birth'] = updatedProfile.dateOfBirth;
      } else {
        _changedFields['date_of_birth'] = null;
      }
    }

    // Gender
    if (originalProfile.gender != updatedProfile.gender) {
      if (updatedProfile.gender != null && updatedProfile.gender!.isNotEmpty) {
        _changedFields['gender'] = updatedProfile.gender;
      } else {
        _changedFields['gender'] = null;
      }
    }

    // Doctor uchun qo'shimcha maydonlar
    if (updatedProfile.isDoctor) {
      // Specialization
      if (originalProfile.specialization != updatedProfile.specialization) {
        if (updatedProfile.specialization != null && updatedProfile.specialization!.isNotEmpty) {
          _changedFields['specialization'] = updatedProfile.specialization;
        } else {
          _changedFields['specialization'] = null;
        }
      }

      // Medical license
      if (originalProfile.medicalLicense != updatedProfile.medicalLicense) {
        if (updatedProfile.medicalLicense != null && updatedProfile.medicalLicense!.isNotEmpty) {
          _changedFields['medical_license'] = updatedProfile.medicalLicense;
        } else {
          _changedFields['medical_license'] = null;
        }
      }

      // Is available
      if (originalProfile.isAvailable != updatedProfile.isAvailable) {
        _changedFields['is_available'] = updatedProfile.isAvailable;
      }
    }
  }

  /// Faqat o'zgargan maydonlarni JSON sifatida qaytarish
  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(_changedFields);
  }

  /// O'zgarishlar mavjudligini tekshirish
  bool get hasChanges => _changedFields.isNotEmpty;

  /// O'zgargan maydonlar ro'yxati
  List<String> get changedFieldNames => _changedFields.keys.toList();

  /// O'zgarishlar sonini qaytarish
  int get changesCount => _changedFields.length;

  @override
  String toString() {
    return 'ProfileUpdateRequest(changedFields: $_changedFields, hasChanges: $hasChanges)';
  }
}