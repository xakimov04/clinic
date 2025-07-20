// lib/core/routes/route_paths.dart
class RoutePaths {
  static const String initialScreen = '/';
  static const String homeScreen = '/home';
  static const String authScreen = '/auth';
  static const String profileScreen = '/profile';
  static const String profileDetailsScreen = '/profile/details';
  static const String newsScreen = '/news';
  static const String appointmentsScreen = '/appointments';
  static const String chatScreen = '/chat';
  static const String chatDetail = '/chat/:chatId';
  static const String doctorDetail = '/doctor/:doctorId';
  static const String illnessDetail = '/illness/:illnessId';

  // Doctor routes
  static const String doctorLogin = '/doctor-login';
  static const String doctorHome = '/doctor-home';
  static const String doctorProfile = '/doctor-profile';
  static const String doctorChat = '/doctor-chat'; // Yangi route
  static const String doctorChatDetail = '/doctor-chat/:chatId'; // Yangi route
  static const String doctorProfileDetails = '/doctor-profile/details';
  static const String appointmentDetailScreen =
      '/doctor-home/appointment-detail';

  static const String receptionsScreen = '/receptions';
}
