import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: DilSenseiApp()));
}

class DilSenseiApp extends StatelessWidget {
  const DilSenseiApp({this.router, super.key});

  /// Dapat di-inject supaya setiap test memakai instance router yang bersih.
  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DilSensei',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router ?? appRouter,
    );
  }
}
