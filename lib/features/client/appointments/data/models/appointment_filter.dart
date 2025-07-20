class AppointmentFilters {
  final String? createdAt;
  final String? patientBirthDate;
  final String? patientFirstName;
  final String? patientLastName;
  final String? patientPhoneNumber;

  const AppointmentFilters({
    this.createdAt,
    this.patientBirthDate,
    this.patientFirstName,
    this.patientLastName,
    this.patientPhoneNumber,
  });

  /// Query parametrlarini yaratish
  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};

    if (createdAt?.isNotEmpty == true) params['created_at'] = createdAt!;
    if (patientBirthDate?.isNotEmpty == true) {
      params['patient_birth_date'] = patientBirthDate!;
    }
    if (patientFirstName?.isNotEmpty == true) {
      params['patient_first_name'] = patientFirstName!;
    }
    if (patientLastName?.isNotEmpty == true) {
      params['patient_last_name'] = patientLastName!;
    }
    if (patientPhoneNumber?.isNotEmpty == true) {
      params['patient_phone_number'] = patientPhoneNumber!;
    }

    return params;
  }

  /// Bo'sh filter ekanligini tekshirish
  bool get isEmpty =>
      (createdAt?.isEmpty ?? true) &&
      (patientBirthDate?.isEmpty ?? true) &&
      (patientFirstName?.isEmpty ?? true) &&
      (patientLastName?.isEmpty ?? true) &&
      (patientPhoneNumber?.isEmpty ?? true);

  /// Filter nusxasini yaratish
  AppointmentFilters copyWith({
    String? createdAt,
    String? patientBirthDate,
    String? patientFirstName,
    String? patientLastName,
    String? patientPhoneNumber,
  }) {
    return AppointmentFilters(
      createdAt: createdAt ?? this.createdAt,
      patientBirthDate: patientBirthDate ?? this.patientBirthDate,
      patientFirstName: patientFirstName ?? this.patientFirstName,
      patientLastName: patientLastName ?? this.patientLastName,
      patientPhoneNumber: patientPhoneNumber ?? this.patientPhoneNumber,
    );
  }

  /// Bo'sh filter yaratish
  static const AppointmentFilters empty = AppointmentFilters();
}
