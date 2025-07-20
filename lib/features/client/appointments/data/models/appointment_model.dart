import 'package:flutter/material.dart';
import 'package:clinic/core/constants/color_constants.dart';

/// Appointment statuslari enum
enum AppointmentStatus {
  pending('pending'),
  confirmed('confirmed'),
  cancelled('cancelled'),
  completed('completed');

  const AppointmentStatus(this.value);
  final String value;

  /// Backend dan kelgan string qiymatni enum ga o'girish
  static AppointmentStatus fromString(String value) {
    return AppointmentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AppointmentStatus.pending,
    );
  }

  /// JSON serialization uchun
  String toJson() => value;
}

/// AppointmentStatus extension - UI properties
extension AppointmentStatusExtension on AppointmentStatus {
  Color get color {
    switch (this) {
      case AppointmentStatus.pending:
        return ColorConstants.warningColor;
      case AppointmentStatus.confirmed:
        return ColorConstants.primaryColor;
      case AppointmentStatus.cancelled:
        return ColorConstants.errorColor;
      case AppointmentStatus.completed:
        return ColorConstants.successColor;
    }
  }

  IconData get icon {
    switch (this) {
      case AppointmentStatus.pending:
        return Icons.access_time_outlined;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.completed:
        return Icons.task_alt_outlined;
    }
  }

  String get displayText {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Ожидается';
      case AppointmentStatus.confirmed:
        return 'Подтверждено';
      case AppointmentStatus.cancelled:
        return 'Отменено';
      case AppointmentStatus.completed:
        return 'Завершено';
    }
  }

  /// Status bo'yicha action button larni ko'rsatish kerakmi
  bool get canCancel =>
      this == AppointmentStatus.pending || this == AppointmentStatus.confirmed;
  bool get canReschedule => this == AppointmentStatus.pending;
  bool get isActive =>
      this != AppointmentStatus.cancelled &&
      this != AppointmentStatus.completed;
}

/// Appointment model - immutable va null-safe
@immutable
class AppointmentModel {
  final int id;
  final int patientId;
  final String patientName;
  final int doctorId;
  final String doctorName;
  final int clinicId;
  final String clinicName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.clinicId,
    required this.clinicName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON dan model yaratish - null safety bilan
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    try {
      return AppointmentModel(
        id: _parseIntField(json['id']),
        patientId: _parseIntField(json['patient']),
        patientName: _parseStringField(json['patient_name']),
        doctorId: _parseIntField(json['doctor']),
        doctorName: _parseStringField(json['doctor_name']),
        clinicId: _parseIntField(json['clinic']),
        clinicName: _parseStringField(json['clinic_name']),
        appointmentDate: _parseDateField(json['date']),
        appointmentTime: _parseStringField(json['time']),
        status: AppointmentStatus.fromString(json['status'] ?? 'pending'),
        notes: json['notes']?.toString().trim().isEmpty ?? true
            ? null
            : json['notes'].toString(),
        createdAt: _parseDateField(json['created_at']),
        updatedAt: _parseDateField(json['updated_at']),
      );
    } catch (e) {
      throw FormatException('AppointmentModel yaratishda xatolik: $e');
    }
  }

  /// Model ni JSON ga o'girish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': patientId,
      'patient_name': patientName,
      'doctor': doctorId,
      'doctor_name': doctorName,
      'clinic': clinicId,
      'clinic_name': clinicName,
      'date': appointmentDate.toIso8601String().split('T')[0],
      'time': appointmentTime,
      'status': status.toJson(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Model nusxasini yaratish ba'zi field larni o'zgartirib
  AppointmentModel copyWith({
    int? id,
    int? patientId,
    String? patientName,
    int? doctorId,
    String? doctorName,
    int? clinicId,
    String? clinicName,
    DateTime? appointmentDate,
    String? appointmentTime,
    AppointmentStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Appointment date va time ni birlashtirib DateTime qaytarish
  DateTime get fullDateTime {
    final timeParts = appointmentTime.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;

    return DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      hour,
      minute,
    );
  }

  /// Appointment o'tmishmi yoki kelajakdami
  bool get isPast => fullDateTime.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }

  /// Formatlangan sana
  String get formattedDate {
    return '${appointmentDate.day.toString().padLeft(2, '0')}.'
        '${appointmentDate.month.toString().padLeft(2, '0')}.'
        '${appointmentDate.year}';
  }

  /// Qisqa ma'lumot (card uchun)
  String get shortInfo => '$doctorName • $formattedDate $appointmentTime';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppointmentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppointmentModel(id: $id, doctor: $doctorName, date: $formattedDate, status: ${status.displayText})';
  }

  // Helper methods for safe parsing
  static int _parseIntField(dynamic value) {
    if (value == null) {
      throw const FormatException('Int field null bo\'lishi mumkin emas');
    }
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Int field ni parse qilishda xatolik: $value');
  }

  static String _parseStringField(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static DateTime _parseDateField(dynamic value) {
    if (value == null) {
      throw const FormatException('Date field null bo\'lishi mumkin emas');
    }
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Date field ni parse qilishda xatolik: $value');
  }
}

/// Appointment modellar bilan ishlash uchun utility extension
extension AppointmentListExtension on List<AppointmentModel> {
  /// Status bo'yicha filtrlash
  List<AppointmentModel> filterByStatus(AppointmentStatus status) {
    return where((appointment) => appointment.status == status).toList();
  }

  /// Приёмы на сегодня
  List<AppointmentModel> get todayAppointments {
    return where((appointment) => appointment.isToday).toList();
  }

  /// Активные приёмы (не отменённые и не завершённые)
  List<AppointmentModel> get activeAppointments {
    return where((appointment) => appointment.status.isActive).toList();
  }

  /// Сортировка по дате
  List<AppointmentModel> sortByDate({bool ascending = true}) {
    final sorted = List<AppointmentModel>.from(this);
    sorted.sort((a, b) {
      final comparison = a.fullDateTime.compareTo(b.fullDateTime);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Группировка по врачу
  Map<String, List<AppointmentModel>> groupByDoctor() {
    final Map<String, List<AppointmentModel>> grouped = {};
    for (final appointment in this) {
      grouped.putIfAbsent(appointment.doctorName, () => []).add(appointment);
    }
    return grouped;
  }
}
