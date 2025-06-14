import 'package:clinic/core/routes/routes.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_model.dart';
import 'package:clinic/features/client/chat/domain/entities/chat_entity.dart';
import 'package:clinic/features/client/chat/presentation/bloc/chat_detail/chat_detail_bloc.dart';
import 'package:clinic/features/client/chat/presentation/pages/chat_detail_screen.dart';
import 'package:clinic/features/client/home/domain/clinics/entities/clinics_entity.dart';
import 'package:clinic/features/client/home/domain/doctors/entities/doctor_entity.dart';
import 'package:clinic/features/client/home/presentation/pages/clinic_details_screen.dart';
import 'package:clinic/features/client/home/presentation/pages/doctor_detail_screen.dart';
import 'package:clinic/features/client/home/presentation/pages/illness_details_screen.dart';
import 'package:clinic/features/doctor/chat/presentation/pages/doctor_chat_detail_screen.dart';
import 'package:clinic/features/doctor/chat/presentation/pages/doctor_chat_screen.dart';
import 'package:clinic/features/doctor/home/presentation/pages/appointment_detail_screen.dart';
import 'package:clinic/features/doctor/home/presentation/pages/doctor_home_screen.dart';
import 'package:clinic/features/doctor/main/pages/doctor_main_screen.dart';
import 'package:clinic/features/profile/presentation/pages/profile_details_screen.dart';
import 'package:clinic/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:clinic/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  // Patient uchun navigator kalitlari
  static final _patientHomeNavigatorKey = GlobalKey<NavigatorState>();
  static final _patientNewsNavigatorKey = GlobalKey<NavigatorState>();
  static final _patientAppointmentsNavigatorKey = GlobalKey<NavigatorState>();
  static final _patientChatNavigatorKey = GlobalKey<NavigatorState>();
  static final _patientProfileNavigatorKey = GlobalKey<NavigatorState>();

  // Doctor uchun navigator kalitlari
  static final _doctorHomeNavigatorKey = GlobalKey<NavigatorState>();
  static final _doctorChatNavigatorKey = GlobalKey<NavigatorState>();
  static final _doctorProfileNavigatorKey = GlobalKey<NavigatorState>();
  static GoRouter get router {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RoutePaths.initialScreen,
      routes: [
        // Splash screen
        GoRoute(
          path: RoutePaths.initialScreen,
          builder: (context, state) => const SplashScreen(),
        ),

        // Auth screen
        GoRoute(
          path: RoutePaths.authScreen,
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: RoutePaths.doctorLogin,
          builder: (context, state) => const DoctorLoginScreen(),
        ),
        GoRoute(
          path: RoutePaths.illnessDetail,
          builder: (context, state) {
            final illnessIdStr = state.pathParameters['illnessId']!;
            int.parse(illnessIdStr);

            // Extra ma'lumotlardan illness entity'ni olish
            final extra = state.extra as Map<String, dynamic>?;
            final illness = extra?['illness'];

            if (illness == null) {
              return const Scaffold(
                body: Center(
                  child: Text('Kasallik topilmadi'),
                ),
              );
            }

            return IllnessDetailsScreen(illness: illness);
          },
        ),
        GoRoute(
          path: RoutePaths.chatDetail,
          builder: (context, state) {
            final chatIdStr = state.pathParameters['chatId']!;
            int.parse(chatIdStr);

            // Extra ma'lumotlardan chat entity'ni olish
            final extra = state.extra as Map<String, dynamic>?;
            final chat = extra?['chat'] as ChatEntity?;

            if (chat == null) {
              // Agar chat entity berilmagan bo'lsa, error page'ga yo'naltirish
              return const Scaffold(
                body: Center(
                  child: Text('Chat topilmadi'),
                ),
              );
            }

            return BlocProvider(
              create: (context) => sl<ChatDetailBloc>(),
              child: ChatDetailScreen(chat: chat),
            );
          },
        ),
        GoRoute(
          path: RoutePaths.doctorChatDetail,
          builder: (context, state) {
            final chatIdStr = state.pathParameters['chatId']!;
            int.parse(chatIdStr);

            // Extra ma'lumotlardan chat entity'ni olish
            final extra = state.extra as Map<String, dynamic>?;
            final chat = extra?['chat'] as ChatEntity?;

            if (chat == null) {
              // Agar chat entity berilmagan bo'lsa, error page'ga yo'naltirish
              return const Scaffold(
                body: Center(
                  child: Text('Chat topilmadi'),
                ),
              );
            }

            return BlocProvider(
              create: (context) => sl<ChatDetailBloc>(),
              child: DoctorChatDetailScreen(chat: chat),
            );
          },
        ),
        GoRoute(
          path: RoutePaths.doctorDetail,
          builder: (context, state) {
            // Extra ma'lumotlardan doctor entity'ni olish
            final extra = state.extra as Map<String, dynamic>?;
            final doctor = extra?['doctor'] as DoctorEntity?;

            if (doctor == null) {
              return const Scaffold(
                body: Center(
                  child: Text('Врач не найден'),
                ),
              );
            }

            return DoctorDetailScreen(doctor: doctor);
          },
        ),

        // Clinic Details Screen
        GoRoute(
          path: '/clinic/:clinicId',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final clinic = extra?['clinic'] as ClinicsEntity?;

            if (clinic == null) {
              return const Scaffold(
                body: Center(
                  child: Text('Klinika topilmadi'),
                ),
              );
            }

            return ClinicDetailsScreen(clinic: clinic);
          },
        ),

        // Profile Details Screen (Global - ikkala role uchun)
        GoRoute(
          path: RoutePaths.profileDetailsScreen,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final user = extra?['user'];

            return BlocProvider.value(
              value: sl<ProfileBloc>(),
              child: ProfileDetailsScreen(user: user),
            );
          },
        ),

        // Patient main screens
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainScreen(navigationShell: navigationShell);
          },
          branches: [
            // Home branch
            StatefulShellBranch(
              navigatorKey: _patientHomeNavigatorKey,
              routes: [
                GoRoute(
                  path: RoutePaths.homeScreen,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: HomeScreen(),
                  ),
                ),
              ],
            ),

            // News branch
            StatefulShellBranch(
              navigatorKey: _patientNewsNavigatorKey,
              routes: [
                GoRoute(
                  path: RoutePaths.newsScreen,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: NewsScreen(),
                  ),
                ),
              ],
            ),

            // Appointments branch
            StatefulShellBranch(
              navigatorKey: _patientAppointmentsNavigatorKey,
              routes: [
                GoRoute(
                  path: RoutePaths.appointmentsScreen,
                  pageBuilder: (context, state) => NoTransitionPage(
                    child: AppointmentsScreen(repository: sl()),
                  ),
                ),
              ],
            ),

            // Chat branch
            StatefulShellBranch(
              navigatorKey: _patientChatNavigatorKey,
              routes: [
                GoRoute(
                  path: RoutePaths.chatScreen,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: ChatScreen(),
                  ),
                ),
              ],
            ),

            // Patient Profile branch
            StatefulShellBranch(
              navigatorKey: _patientProfileNavigatorKey,
              routes: [
                GoRoute(
                  path: RoutePaths.profileScreen,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: ProfileScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: RoutePaths.appointmentDetailScreen,
          pageBuilder: (context, state) {
            final appointment = state.extra as Map<String, dynamic>?;
            final appointments =
                appointment?['appointment'] as AppointmentModel;
            return NoTransitionPage(
              child: AppointmentDetailScreen(appointment: appointments),
            );
          },
        ),
        // Doctor main screen
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return DoctorMainScreen(navigationShell: navigationShell);
          },
          branches: [
            // Doctor Home branch
            StatefulShellBranch(
              navigatorKey: _doctorHomeNavigatorKey,
              routes: [
                GoRoute(
                  path: RoutePaths.doctorHome,
                  pageBuilder: (context, state) => NoTransitionPage(
                    child: DoctorHomeScreen(
                      repository: sl(),
                    ),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _doctorChatNavigatorKey,
              routes: [
                GoRoute(
                  path: RoutePaths.doctorChat,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: DoctorChatScreen(),
                  ),
                ),
              ],
            ),

            // Doctor Profile branch (umumiy ProfileScreen)
            StatefulShellBranch(
              navigatorKey: _doctorProfileNavigatorKey,
              routes: [
                GoRoute(
                  path: RoutePaths.doctorProfile,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: ProfileScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
