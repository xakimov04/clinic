class ClinicsEntity {
  final int id;
  final String uuid;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String photo;
  final int doctorsCount;

  ClinicsEntity({
    required this.id,
    required this.uuid,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.doctorsCount,
    required this.photo,
  });
}
