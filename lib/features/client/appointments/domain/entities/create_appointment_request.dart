import 'package:flutter/material.dart';

class CreateAppointmentRequest {
  final String specialization;
  final DateTime date;
  final TimeOfDay timeBegin;
  final String employeeId;
  final String clinicId;
  final String comment;

  const CreateAppointmentRequest({
    required this.specialization,
    required this.date,
    required this.timeBegin,
    required this.employeeId,
    required this.clinicId,
    this.comment = '',
  });

  Map<String, dynamic> toJson() {
    final combinedDateTime =
        DateTime(1, 1, 1, timeBegin.hour, timeBegin.minute);
    final isoString = combinedDateTime.toIso8601String();
    final trimmedIsoString = isoString.replaceFirst(RegExp(r'\.000$'), '');

    return {
      'specialization': specialization,
      'date': '${date.toIso8601String().split('T')[0]}T00:00:00',
      'time_begin': trimmedIsoString,
      'employee_id': employeeId,
      'clinic_id': clinicId,
      'comment': comment,
    };
  }
}
