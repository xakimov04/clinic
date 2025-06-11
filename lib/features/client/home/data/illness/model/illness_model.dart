import 'package:clinic/features/client/home/data/doctors/models/doctor_model.dart';
import 'package:clinic/features/client/home/domain/illness/entities/illness_entities.dart';

class IllnessModel extends IllnessEntities {
  IllnessModel({
    required super.id,
    required super.name,
    required super.description,
    required super.doctors,
  });

  factory IllnessModel.fromJson(Map<String, dynamic> json) {
    return IllnessModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      doctors: (json['doctors'] as List<dynamic>?)
              ?.map((doctor) => DoctorModel.fromJson(doctor))
              .toList() ??
          [],
    );
  }
}
