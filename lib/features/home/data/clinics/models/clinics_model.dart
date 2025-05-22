import 'package:clinic/features/home/domain/clinics/entities/clinics_entity.dart';

class ClinicsModel extends ClinicsEntity {
  ClinicsModel({required super.id, required super.uuid, required super.name});

  factory ClinicsModel.fromJson(Map<String, dynamic> json) {
    return ClinicsModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? "",
      name: json['name'] ?? "",
    );
  }
}
