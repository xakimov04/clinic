import 'package:go_router/go_router.dart';
import 'routes.dart';

class AppRouter {
  static GoRouter get router {
    return GoRouter(
      initialLocation: RoutePaths.initalScreen,
      routes: [],
    );
  }
}
