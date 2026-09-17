import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/lab_screen.dart';
import 'screens/lab_3d_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/lab', builder: (_, __) => const LabScreen()),
    GoRoute(path: '/lab3d', builder: (_, __) => const Lab3DScreen()),
  ],
);

class VirtualChemLabApp extends StatelessWidget {
  const VirtualChemLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Virtual Chemistry Lab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}