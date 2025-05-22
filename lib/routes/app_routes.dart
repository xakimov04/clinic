import 'package:clinic/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  // Har bir screen state-ni saqlash uchun key
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _homeNavigatorKey = GlobalKey<NavigatorState>();
  static final _newsNavigatorKey = GlobalKey<NavigatorState>();
  static final _appointmentsNavigatorKey = GlobalKey<NavigatorState>();
  static final _chatNavigatorKey = GlobalKey<NavigatorState>();
  static final _profileNavigatorKey = GlobalKey<NavigatorState>();

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

        // Main screens with bottom navigation
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            // StatefulShellRoute orqali MainScreen-ni qurish
            return MainScreen(navigationShell: navigationShell);
          },
          branches: [
            // 1. Home branch
            StatefulShellBranch(
              navigatorKey: _homeNavigatorKey,
              routes: [
                GoRoute(
                  path: RoutePaths.homeScreen,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: HomeScreen(),
                  ),
                ),
              ],
            ),

            StatefulShellBranch(
              navigatorKey: _newsNavigatorKey,
              routes: [
                GoRoute(
                  path: RoutePaths.newsScreen,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: NewsScreen(),
                  ),
                ),
              ],
            ),
            // 2. Appointments branch
            StatefulShellBranch(
              navigatorKey: _appointmentsNavigatorKey,
              routes: [
                GoRoute(
                  path: RoutePaths.appointmentsScreen,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: AppointmentsScreen(),
                  ),
                ),
              ],
            ),

            // 3. Chat branch
            StatefulShellBranch(
              navigatorKey: _chatNavigatorKey,
              routes: [
                GoRoute(
                  path: RoutePaths.chatScreen,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: ChatScreen(),
                  ),
                ),
              ],
            ),

            // 4. Profile branch
            StatefulShellBranch(
              navigatorKey: _profileNavigatorKey,
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
      ],
    );
  }
}
