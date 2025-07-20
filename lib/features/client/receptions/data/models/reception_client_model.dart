import 'package:clinic/features/client/receptions/domain/entities/reception_client_entity.dart';

class ReceptionClientModel extends ReceptionClientEntity {
  const ReceptionClientModel({
    required super.id,
    required super.fullName,
    required super.lastName,
    required super.firstName,
    required super.middleName,
    required super.specialization,
    required super.organizationId,
    super.mainServices,
    super.shortDescription,
  });

  factory ReceptionClientModel.fromJson(Map<String, dynamic> json) {
    return ReceptionClientModel(
      id: json['id'] as String,
      fullName: json['наименование'] as String,
      lastName: json['фамилия'] as String,
      firstName: json['name'] as String,
      middleName: json['отчество'] as String,
      specialization: json['специализация'] as String,
      organizationId: json['организация'] as String,
      mainServices: json['основныеуслуги'] as String?,
      shortDescription: json['краткоеописание'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'наименование': fullName,
      'фамилия': lastName,
      'name': firstName,
      'отчество': middleName,
      'специализация': specialization,
      'организация': organizationId,
      'основныеуслуги': mainServices,
      'краткоеописание': shortDescription,
    };
  }
}
