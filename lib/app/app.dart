import 'package:clinic/app/bloc_providers.dart';
import 'package:clinic/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  final GoRouter router;
  
  const App({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: appBlocProviders,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}
