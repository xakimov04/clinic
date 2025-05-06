import 'package:clinic/features/auth/presentation/screens/auth_screen.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

class AppRouter {
  static GoRouter get router {
    return GoRouter(
      initialLocation: RoutePaths.initialScreen,
      routes: [
        GoRoute(
          path: RoutePaths.initialScreen,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RoutePaths.homeScreen,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: RoutePaths.authScreen,
          builder: (context, state) => const AuthScreen(),
        ),
      ],
    );
  }
}
