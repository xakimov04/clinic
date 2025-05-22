import 'package:clinic/core/network/network_service.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'di/injection_container.dart';
import 'routes/app_routes.dart';

final router = AppRouter.router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NetworkService.initializeInterceptors();
  await init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return App(router: router);
  }
}
