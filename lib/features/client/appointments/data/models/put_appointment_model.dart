import 'package:clinic/features/client/appointments/domain/entities/put_appointment_entity.dart';

class PutAppointmentModel extends PutAppointmentEntity {
  PutAppointmentModel({
    required super.doctor,
    required super.clinic,
    required super.status,
  });

  factory PutAppointmentModel.fromJson(Map<String, dynamic> json) {
    return PutAppointmentModel(
      doctor: json['doctor'] ?? 0,
      clinic: json['clinic'] ?? 0,
      status: json['status'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor': doctor,
      'clinic': clinic,
      'status': status,
    };
  }
}
