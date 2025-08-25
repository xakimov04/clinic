import 'package:clinic/features/client/home/domain/clinics/entities/clinics_entity.dart';

class ClinicsModel extends ClinicsEntity {
  ClinicsModel({
    required super.id,
    required super.uuid,
    required super.name,
    required super.address,
    required super.phone,
    required super.email,
    required super.doctorsCount,
    required super.photo,
  });

  factory ClinicsModel.fromJson(Map<String, dynamic> json) {
    return ClinicsModel(
        id: json['id'] ?? 0,
        uuid: json['uuid'] ?? "",
        name: json['name'] ?? "",
        address: json['address'] ?? "",
        phone: json['phone'] ?? "",
        email: json['email'] ?? "",
        doctorsCount: json['doctors_count'] ?? 0,
        photo: json['photo'] ?? "");
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
    };
  }
}
