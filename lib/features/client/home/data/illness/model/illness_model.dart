import 'package:clinic/features/client/home/domain/illness/entities/illness_entities.dart';

class IllnessModel extends IllnessEntities {
  IllnessModel({
    required super.id,
    required super.specialization,
  });

  factory IllnessModel.fromJson(Map<String, dynamic> json) {
    return IllnessModel(
      id: json['id'] ?? 0,
      specialization: json['specialization'] ?? "",
    );
  }
}
