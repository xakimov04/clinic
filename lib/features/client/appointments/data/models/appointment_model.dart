import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AppointmentsViewState { initial, loading, loaded, error, refreshing }

enum AppointmentStatus {
  created('Ожидает'),
  scheduled('Подтверждено'),
  confirmed('Подтверждено'),
  booked('Забронирована'),
  completed('Завершено'),
  cancelled('Отменена'),
  saleProcessed('Оформлена продажа'),
  appointmentHeld('Проведен прием');

  const AppointmentStatus(this.displayName);
  final String displayName;

  // Status rangini aniqlash
  Color get color {
    switch (this) {
      case AppointmentStatus.created:
      case AppointmentStatus.scheduled:
        return const Color(0xFFFF9800); // Orange
      case AppointmentStatus.confirmed:
      case AppointmentStatus.booked:
        return const Color(0xFF2196F3); // Blue
      case AppointmentStatus.completed:
      case AppointmentStatus.appointmentHeld:
        return const Color(0xFF4CAF50); // Green
      case AppointmentStatus.cancelled:
        return const Color(0xFFF44336); // Red
      case AppointmentStatus.saleProcessed:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  // Status icon-ini aniqlash
  IconData get icon {
    switch (this) {
      case AppointmentStatus.created:
        return Icons.web_outlined;
      case AppointmentStatus.scheduled:
        return Icons.schedule_outlined;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline;
      case AppointmentStatus.booked:
        return Icons.bookmark_outline;
      case AppointmentStatus.completed:
        return Icons.task_alt_outlined;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.saleProcessed:
        return Icons.payment_outlined;
      case AppointmentStatus.appointmentHeld:
        return Icons.medical_services_outlined;
    }
  }

  // JSON string dan enum ga convert qilish
  static AppointmentStatus fromString(String status) {
    switch (status) {
      case 'Создана на сайте':
        return AppointmentStatus.created;
      case 'Запланирована':
        return AppointmentStatus.scheduled;
      case 'Подтверждено':
        return AppointmentStatus.confirmed;
      case 'Забронирована':
        return AppointmentStatus.booked;
      case 'Выполнена':
        return AppointmentStatus.completed;
      case 'Отменена':
        return AppointmentStatus.cancelled;
      case 'Оформлена продажа':
        return AppointmentStatus.saleProcessed;
      case 'Проведен прием':
        return AppointmentStatus.appointmentHeld;
      default:
        return AppointmentStatus.created;
    }
  }
}

// appointment_model.dart
class AppointmentModel {
  final String uid;
  final AppointmentStatus status;
  final DateTime dataZayavki;
  final DateTime dataNachalaZapisi;
  final DateTime dataOkonchaniyaZapisi;
  final String patientFirstName;
  final String patientLastname;
  final DateTime patientBirthDate;
  final String patientPhoneNumber;
  final String doctorUid;
  final String doctorName;
  final String branch;
  final String clinic;

  const AppointmentModel({
    required this.uid,
    required this.status,
    required this.dataZayavki,
    required this.dataNachalaZapisi,
    required this.dataOkonchaniyaZapisi,
    required this.patientFirstName,
    required this.patientLastname,
    required this.patientBirthDate,
    required this.patientPhoneNumber,
    required this.doctorUid,
    required this.doctorName,
    required this.branch,
    required this.clinic,
  });

  // JSON dan model yaratish
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      uid: json['uid'] as String,
      status: AppointmentStatus.fromString(json['sostoyanie'] as String),
      dataZayavki: DateTime.parse(json['data_zayavki'] as String),
      dataNachalaZapisi: DateTime.parse(json['data_nachala_zapisi'] as String),
      dataOkonchaniyaZapisi:
          DateTime.parse(json['data_okonchaniya_zapisi'] as String),
      patientFirstName: json['patient_first_name'] as String,
      patientLastname: json['patient_lastname'] as String,
      patientBirthDate: DateTime.parse(json['patient_birth_date'] as String),
      patientPhoneNumber: json['patient_phone_number'] as String,
      doctorUid: json['doctor_uid'] as String,
      doctorName: json['doctor_name'] as String,
      branch: json['branch'] as String,
      clinic: json['clinic'] as String,
    );
  }

  // Formatlangan sana
  String get formattedDate {
    return DateFormat('dd.MM.yyyy', 'ru').format(dataNachalaZapisi);
  }

  // Formatlangan vaqt
  String get appointmentTime {
    return DateFormat('HH:mm', 'ru').format(dataNachalaZapisi);
  }

  // Klinika nomi
  String get clinicName => branch.isNotEmpty ? branch : clinic;

  // Bugunmi?
  bool get isToday {
    final now = DateTime.now();
    final appointmentDate = dataNachalaZapisi;
    return now.year == appointmentDate.year &&
        now.month == appointmentDate.month &&
        now.day == appointmentDate.day;
  }
}

// List extensions
extension AppointmentListExtensions on List<AppointmentModel> {
  List<AppointmentModel> sortByDate() {
    final sorted = List<AppointmentModel>.from(this);
    sorted.sort((a, b) => a.dataNachalaZapisi.compareTo(b.dataNachalaZapisi));
    return sorted;
  }

  List<AppointmentModel> filterByStatuses(List<AppointmentStatus> statuses) {
    return where((appointment) => statuses.contains(appointment.status))
        .toList();
  }
}

class TabConfig {
  final List<AppointmentStatus> statuses;
  final String label;
  final IconData icon;

  const TabConfig({
    required this.statuses,
    required this.label,
    required this.icon,
  });

  static const List<TabConfig> tabConfigs = [
    TabConfig(
      statuses: [
        AppointmentStatus.created,
      ],
      label: 'Ожидает',
      icon: Icons.access_time_outlined,
    ),
    TabConfig(
      statuses: [
        AppointmentStatus.scheduled,
      ],
      label: 'Подтверждено',
      icon: Icons.check_circle_outline,
    ),
    TabConfig(
      statuses: [
        AppointmentStatus.completed,
      ],
      label: 'Завершено',
      icon: Icons.task_alt_outlined,
    ),
  ];
}
