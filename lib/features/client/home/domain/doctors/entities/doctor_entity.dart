class DoctorEntity {
  final int id;
  final String username;
  final String email;
  final String name;
  final String avatar;
  final String fullName;
  final String specialization;
  final bool isAvailable;
  final String medicalLicense;

  const DoctorEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.avatar,
    required this.fullName,
    required this.specialization,
    required this.isAvailable,
    required this.medicalLicense,
  });
}
