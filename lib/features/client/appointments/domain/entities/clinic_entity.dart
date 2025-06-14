class ClinicEntity {
  final int id;
  final String uuid;
  final String name;
  final String address;
  final String phone;
  final String email;
  final int doctorsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClinicEntity({
    required this.id,
    required this.uuid,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.doctorsCount,
    required this.createdAt,
    required this.updatedAt,
  });
}