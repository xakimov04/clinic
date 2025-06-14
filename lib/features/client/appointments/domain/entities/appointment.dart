import 'package:flutter/material.dart';
import 'package:clinic/core/constants/color_constants.dart';

enum AppointmentStatus { pending, confirmed, completed }

extension AppointmentStatusExtension on AppointmentStatus {
  Color get color {
    switch (this) {
      case AppointmentStatus.pending:
        return ColorConstants.primaryColor;
      case AppointmentStatus.confirmed:
        return ColorConstants.successColor;
      case AppointmentStatus.completed:
        return ColorConstants.successColor;
    }
  }

  IconData get icon {
    switch (this) {
      case AppointmentStatus.pending:
        return Icons.access_time;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.completed:
        return Icons.check_circle;
    }
  }

  String get text {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Ожидает';
      case AppointmentStatus.confirmed:
        return 'Подтверждено';
      case AppointmentStatus.completed:
        return 'Завершено';
    }
  }
}

class Appointment {
  final int id;
  final int patient;
  final String patientName;
  final int doctor;
  final String doctorName;
  final int clinic;
  final String clinicName;
  final DateTime date;
  final String time;
  final AppointmentStatus status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.patient,
    required this.patientName,
    required this.doctor,
    required this.doctorName,
    required this.clinic,
    required this.clinicName,
    required this.date,
    required this.time,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
}
