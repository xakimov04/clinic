import 'package:clinic/features/client/receptions/domain/entities/reception_info_entity.dart';

class ReceptionInfoModel extends ReceptionInfoEntity {
  ReceptionInfoModel({
    super.diagnosis,
    super.treatmentPlan,
    super.attachedFiles,
  });

  factory ReceptionInfoModel.fromJson(Map<String, dynamic> json) {
    final attachedList = (json['attached_files'] as List<dynamic>?)
        ?.map((e) => AttachedFile.fromJson(e as Map<String, dynamic>))
        .toList();

    return ReceptionInfoModel(
      diagnosis: json['диагноз'] ?? "",
      treatmentPlan: json['планлечения'] ?? "",
      attachedFiles: attachedList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'диагноз': diagnosis,
      'планлечения': treatmentPlan,
      'прикрепленныйфайл': attachedFiles,
    };
  }
}
