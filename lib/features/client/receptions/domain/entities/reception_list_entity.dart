class ReceptionListEntity {
  final String id;
  final DateTime visitDate;
  final String serviceName;
  final String clientName;
  final DateTime dateTime;

  ReceptionListEntity({
    required this.id,
    required this.visitDate,
    required this.serviceName,
    required this.clientName,
    required this.dateTime,
  });
}
