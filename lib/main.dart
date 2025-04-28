import 'package:clinic/core/network/network_service.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'di/injection_container.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  NetworkService.initializeInterceptors();
  
  await init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
