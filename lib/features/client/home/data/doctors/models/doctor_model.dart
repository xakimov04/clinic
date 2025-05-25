import '../../../domain/doctors/entities/doctor_entity.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.username,
    required super.email,
    required super.name,
    required super.avatar,
    required super.fullName,
    required super.specialization,
    required super.isAvailable,
    required super.medicalLicense,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? "",
      email: json['email'] ?? "",
      name: json['name'] ?? "",
      avatar: json['avatar'] ?? "",
      fullName: json['full_name'] ?? "",
      specialization: json['specialization'] ?? "",
      isAvailable: json['is_available'] ?? false,
      medicalLicense: json['medical_license'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'avatar': avatar,
      'full_name': fullName,
      'specialization': specialization,
      'is_available': isAvailable,
      'medical_license': medicalLicense,
    };
  }
}
