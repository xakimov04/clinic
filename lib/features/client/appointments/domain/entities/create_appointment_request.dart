class CreateAppointmentRequest {
  final int doctorId;
  final int clinicId;
  final DateTime date;
  final String time;
  final String notes;

  const CreateAppointmentRequest({
    required this.doctorId,
    required this.clinicId,
    required this.date,
    required this.time,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'doctor': doctorId,
      'clinic': clinicId,
      'date':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'time': time,
      'notes': notes,
    };
  }
}
