import 'package:clinic/core/network/network_service.dart';
import 'package:clinic/core/service/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'core/routes/app_routes.dart';

final router = AppRouter.router;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NetworkService.initializeInterceptors();
  await init();
  await FCMService.initFCM();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.instance.getToken();
    return App(router: router);
  }
}
