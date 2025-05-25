
import '../../../domain/doctors/entities/doctor_entity.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.description,
    required super.pricePerVisit,
    required super.clinics,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      description: json['description'] as String,
      pricePerVisit: json['price_per_visit'] as String,
      clinics: (json['clinics'] as List<dynamic>).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'description': description,
      'price_per_visit': pricePerVisit,
      'clinics': clinics,
    };
  }
}
