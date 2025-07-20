import 'package:clinic/features/client/receptions/domain/entities/reception_info_entity.dart';

class ReceptionInfoModel extends ReceptionInfoEntity {
  ReceptionInfoModel({
    super.diagnosis,
    super.treatmentPlan,
    super.attachedFile,
  });

  factory ReceptionInfoModel.fromJson(Map<String, dynamic> json) {
    return ReceptionInfoModel(
      diagnosis: json['диагноз'] as String?,
      treatmentPlan: json['планлечения'] as String?,
      attachedFile: _cleanString(json['прикрепленныйфайл']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'диагноз': diagnosis,
      'планлечения': treatmentPlan,
      'прикрепленныйфайл': attachedFile,
    };
  }

  static String? _cleanString(dynamic value) {
    if (value is String) {
      final cleaned = value.trim();
      return cleaned.isEmpty ? null : cleaned;
    }
    return null;
  }
}
