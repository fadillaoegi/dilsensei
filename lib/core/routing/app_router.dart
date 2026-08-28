import 'package:go_router/go_router.dart';

import '../../features/lesson/presentation/screens/drill_session_screen.dart';
import '../../features/monetization/presentation/screens/paywall_screen.dart';
import 'app_gate.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const paywall = '/paywall';
  static const session = '/session';

  /// Path sesi untuk satu modul, misalnya `/session/hiragana-a-row`.
  static String sessionFor(String moduleId) => '$session/$moduleId';
}

GoRouter createAppRouter({String initialLocation = AppRoutes.home}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const AppGate(),
      ),
      GoRoute(
        path: AppRoutes.paywall,
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.session}/:moduleId',
        builder: (context, state) =>
            DrillSessionScreen(moduleId: state.pathParameters['moduleId']!),
      ),
    ],
  );
}

final GoRouter appRouter = createAppRouter();
