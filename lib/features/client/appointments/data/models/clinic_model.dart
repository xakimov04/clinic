import 'package:clinic/features/client/appointments/domain/entities/clinic_entity.dart';

class ClinicModel extends ClinicEntity {
  const ClinicModel({
    required super.id,
    required super.uuid,
    required super.name,
    required super.address,
    required super.phone,
    required super.email,
    required super.doctorsCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'],
      uuid: json['uuid'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      doctorsCount: json['doctors_count'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'doctors_count': doctorsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
