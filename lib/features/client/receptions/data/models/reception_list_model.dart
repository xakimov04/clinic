import 'package:clinic/features/client/receptions/domain/entities/reception_list_entity.dart';

class ReceptionListModel extends ReceptionListEntity {
  ReceptionListModel({
    required super.id,
    required super.visitDate,
    required super.serviceName,
    required super.clientName,
    required super.dateTime,
  });

  factory ReceptionListModel.fromJson(Map<String, dynamic> json) {
    return ReceptionListModel(
      id: json['id'],
      visitDate: DateTime.parse(json['visit_date']),
      serviceName: json['service_name'],
      clientName: json['наименованиеклиента'],
      dateTime: DateTime.parse('${json['date']}T${json['time']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visit_date': visitDate.toIso8601String(),
      'service_name': serviceName,
      'наименованиеклиента': clientName,
      'date': dateTime.toIso8601String().split('T')[0],
      'time': dateTime.toIso8601String().split('T')[1].split('.').first,
    };
  }
}
