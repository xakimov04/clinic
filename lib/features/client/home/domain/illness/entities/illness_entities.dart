import 'package:clinic/features/client/home/domain/doctors/entities/doctor_entity.dart';

class IllnessEntities {
  final int id;
  final String name;
  final String description;
  final List<DoctorEntity> doctors;

  const IllnessEntities({
    required this.id,
    required this.name,
    required this.description,
    required this.doctors,
  });
}
