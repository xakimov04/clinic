import 'package:flutter/material.dart';
import 'package:clinic/core/constants/color_constants.dart';

enum AppointmentStatus { active, completed }

extension AppointmentStatusExtension on AppointmentStatus {
  Color get color {
    switch (this) {
      case AppointmentStatus.active:
        return ColorConstants.primaryColor;
      case AppointmentStatus.completed:
        return ColorConstants.successColor;
    }
  }

  IconData get icon {
    switch (this) {
      case AppointmentStatus.active:
        return Icons.access_time;
      case AppointmentStatus.completed:
        return Icons.check_circle;
    }
  }

  String get text {
    switch (this) {
      case AppointmentStatus.active:
        return 'Ожидает';
      case AppointmentStatus.completed:
        return 'Завершено';
    }
  }
}

class AppointmentEntity {
  final int? id;
  final int doctorId;
  final int clinicId;
  final DateTime date;
  final String time;
  final String? notes;
  final AppointmentStatus status;
  final String? doctorName;
  final String? clinicName;
  final String? doctorSpecialization;

  const AppointmentEntity({
    this.id,
    required this.doctorId,
    required this.clinicId,
    required this.date,
    required this.time,
    this.notes,
    this.status = AppointmentStatus.active,
    this.doctorName,
    this.clinicName,
    this.doctorSpecialization,
  });

  AppointmentEntity copyWith({
    int? id,
    int? doctorId,
    int? clinicId,
    DateTime? date,
    String? time,
    String? notes,
    AppointmentStatus? status,
    String? doctorName,
    String? clinicName,
    String? doctorSpecialization,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      clinicId: clinicId ?? this.clinicId,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      doctorName: doctorName ?? this.doctorName,
      clinicName: clinicName ?? this.clinicName,
      doctorSpecialization: doctorSpecialization ?? this.doctorSpecialization,
    );
  }
}
