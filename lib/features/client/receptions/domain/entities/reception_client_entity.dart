class ReceptionClientEntity {
  final String id;
  final String fullName;
  final String lastName;
  final String firstName;
  final String middleName;
  final String specialization;
  final String organizationId;
  final String? mainServices;
  final String? shortDescription;

  const ReceptionClientEntity({
    required this.id,
    required this.fullName,
    required this.lastName,
    required this.firstName,
    required this.middleName,
    required this.specialization,
    required this.organizationId,
    this.mainServices,
    this.shortDescription,
  });
}
