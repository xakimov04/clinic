class DoctorEntity {
  final int id;
  final String firstName;
  final String lastName;
  final String description;
  final String pricePerVisit;
  final List<String> clinics;

  const DoctorEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.description,
    required this.pricePerVisit,
    required this.clinics,
  });
}
