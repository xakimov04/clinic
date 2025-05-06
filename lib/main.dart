import 'package:clinic/core/network/network_service.dart';
import 'package:flutter/material.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';
import 'app.dart';
import 'di/injection_container.dart';
import 'routes/app_routes.dart';

final router = AppRouter.router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NetworkService.initializeInterceptors();
  await VKID.getInstance();
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
