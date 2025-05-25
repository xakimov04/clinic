import 'package:clinic/core/routes/routes.dart';
import 'package:clinic/features/doctor/home/presentation/pages/doctor_home_screen.dart';
import 'package:clinic/features/doctor/main/pages/doctor_main_screen.dart';
import 'package:flutter/material.dart';
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
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: AppointmentsScreen(),
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
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: DoctorHomeScreen(),
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
