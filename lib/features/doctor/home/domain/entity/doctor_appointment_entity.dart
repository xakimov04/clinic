import 'package:equatable/equatable.dart';

class DoctorAppointmentEntity extends Equatable {
  final String uid;
  final String sostoyanie;
  final DateTime dataZayavki;
  final DateTime dataNachalaZapisi;
  final DateTime dataOkonchaniyaZapisi;
  final String patientFirstName;
  final String patientLastname;
  final DateTime patientBirthDate;
  final String patientPhoneNumber;

  const DoctorAppointmentEntity({
    required this.uid,
    required this.sostoyanie,
    required this.dataZayavki,
    required this.dataNachalaZapisi,
    required this.dataOkonchaniyaZapisi,
    required this.patientFirstName,
    required this.patientLastname,
    required this.patientBirthDate,
    required this.patientPhoneNumber,
  });

  @override
  List<Object?> get props => [
        uid,
        sostoyanie,
        dataZayavki,
        dataNachalaZapisi,
        dataOkonchaniyaZapisi,
        patientFirstName,
        patientLastname,
        patientBirthDate,
        patientPhoneNumber,
      ];

  // Yoshi hisoblanishi uchun helper method
  int get patientAge {
    final now = DateTime.now();
    final age = now.year - patientBirthDate.year;
    if (now.month < patientBirthDate.month ||
        (now.month == patientBirthDate.month &&
            now.day < patientBirthDate.day)) {
      return age - 1;
    }
    return age;
  }

  // To'liq ism
  String get patientFullName => '$patientFirstName $patientLastname';

  // Zayovka vaqti format
  String get formattedDataZayavki {
    return '${dataZayavki.day.toString().padLeft(2, '0')}.${dataZayavki.month.toString().padLeft(2, '0')}.${dataZayavki.year} ${dataZayavki.hour.toString().padLeft(2, '0')}:${dataZayavki.minute.toString().padLeft(2, '0')}';
  }

  // Yozilish vaqti format
  String get formattedAppointmentTime {
    return '${dataNachalaZapisi.day.toString().padLeft(2, '0')}.${dataNachalaZapisi.month.toString().padLeft(2, '0')}.${dataNachalaZapisi.year} ${dataNachalaZapisi.hour.toString().padLeft(2, '0')}:${dataNachalaZapisi.minute.toString().padLeft(2, '0')} - ${dataOkonchaniyaZapisi.hour.toString().padLeft(2, '0')}:${dataOkonchaniyaZapisi.minute.toString().padLeft(2, '0')}';
  }
}
