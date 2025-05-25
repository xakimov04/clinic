enum UserRole {
  client('CLIENT'),
  doctor('DOCTOR');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DOCTOR':
        return UserRole.doctor;
      case 'CLIENT':
        return UserRole.client;

      default:
        return UserRole.client;
    }
  }
}
