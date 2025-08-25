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
    super.clinic,
    super.photo,
  });

  factory ReceptionClientModel.fromJson(Map<String, dynamic> json) {
    return ReceptionClientModel(
      id: json['id'] ?? "",
      fullName: json['наименование'] ?? "",
      lastName: json['фамилия'] ?? "",
      firstName: json['name'] ?? "",
      middleName: json['отчество'] ?? "",
      specialization: json['специализация'] ?? "",
      organizationId: json['организация'] ?? "",
      mainServices: json['основныеуслуги'] ?? "",
      shortDescription: json['краткоеописание'] ?? "",
      clinic: json['clinic'] ?? "",
      photo: json['photo'] ?? "",
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
      'clinic': clinic,
      'photo': photo,
    };
  }
}
