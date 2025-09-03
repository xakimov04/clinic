import 'package:clinic/features/doctor/home/domain/entity/doctor_appointment_entity.dart';

class DoctorAppointmentModel extends DoctorAppointmentEntity {
  const DoctorAppointmentModel({
    required super.uid,
    required super.sostoyanie,
    required super.dataZayavki,
    required super.dataNachalaZapisi,
    required super.dataOkonchaniyaZapisi,
    required super.patientFirstName,
    required super.patientLastname,
    required super.patientBirthDate,
    required super.patientPhoneNumber,
    required super.chatGuid,
  });

  factory DoctorAppointmentModel.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentModel(
      uid: json['uid']?.toString() ?? '',
      sostoyanie: json['sostoyanie']?.toString() ?? '',
      dataZayavki: json['data_zayavki'] != null
          ? DateTime.parse(json['data_zayavki'])
          : DateTime.now(),
      dataNachalaZapisi: json['data_nachala_zapisi'] != null
          ? DateTime.parse(json['data_nachala_zapisi'])
          : DateTime.now(),
      dataOkonchaniyaZapisi: json['data_okonchaniya_zapisi'] != null
          ? DateTime.parse(json['data_okonchaniya_zapisi'])
          : DateTime.now(),
      patientFirstName: json['patient_first_name']?.toString() ?? '',
      patientLastname: json['patient_lastname']?.toString() ?? '',
      patientBirthDate: json['patient_birth_date'] != null
          ? DateTime.parse(json['patient_birth_date'])
          : DateTime(2000, 1, 1),
      patientPhoneNumber: json['patient_phone_number']?.toString() ?? '',
      chatGuid: json['chat_guid'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'sostoyanie': sostoyanie,
      'data_zayavki': dataZayavki.toIso8601String(),
      'data_nachala_zapisi': dataNachalaZapisi.toIso8601String(),
      'data_okonchaniya_zapisi': dataOkonchaniyaZapisi.toIso8601String(),
      'patient_first_name': patientFirstName,
      'patient_lastname': patientLastname,
      'patient_birth_date': patientBirthDate.toIso8601String(),
      'patient_phone_number': patientPhoneNumber,
    };
  }

  factory DoctorAppointmentModel.fromEntity(DoctorAppointmentEntity entity) {
    return DoctorAppointmentModel(
      uid: entity.uid,
      sostoyanie: entity.sostoyanie,
      dataZayavki: entity.dataZayavki,
      dataNachalaZapisi: entity.dataNachalaZapisi,
      dataOkonchaniyaZapisi: entity.dataOkonchaniyaZapisi,
      patientFirstName: entity.patientFirstName,
      patientLastname: entity.patientLastname,
      patientBirthDate: entity.patientBirthDate,
      patientPhoneNumber: entity.patientPhoneNumber,
      chatGuid: entity.chatGuid
    );
  }

  DoctorAppointmentModel copyWith({
    String? uid,
    String? sostoyanie,
    DateTime? dataZayavki,
    DateTime? dataNachalaZapisi,
    DateTime? dataOkonchaniyaZapisi,
    String? patientFirstName,
    String? patientLastname,
    DateTime? patientBirthDate,
    String? patientPhoneNumber,
    String? chatGuid,
  }) {
    return DoctorAppointmentModel(
      uid: uid ?? this.uid,
      sostoyanie: sostoyanie ?? this.sostoyanie,
      dataZayavki: dataZayavki ?? this.dataZayavki,
      dataNachalaZapisi: dataNachalaZapisi ?? this.dataNachalaZapisi,
      dataOkonchaniyaZapisi:
          dataOkonchaniyaZapisi ?? this.dataOkonchaniyaZapisi,
      patientFirstName: patientFirstName ?? this.patientFirstName,
      patientLastname: patientLastname ?? this.patientLastname,
      patientBirthDate: patientBirthDate ?? this.patientBirthDate,
      patientPhoneNumber: patientPhoneNumber ?? this.patientPhoneNumber,
      chatGuid: chatGuid ?? this.chatGuid,
    );
  }

  // Lista JSON dan list model yaratish
  static List<DoctorAppointmentModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => DoctorAppointmentModel.fromJson(json))
        .toList();
  }
}
