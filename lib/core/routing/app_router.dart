import 'package:go_router/go_router.dart';

import '../../features/kana/domain/kana_chart.dart';
import '../../features/kana/presentation/screens/kana_chart_screen.dart';
import '../../features/lesson/presentation/screens/drill_session_screen.dart';
import '../../features/lesson/presentation/screens/insights_screen.dart';
import '../../features/lesson/presentation/screens/training_record_screen.dart';
import '../../features/monetization/presentation/screens/paywall_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/diagnostics_screen.dart';
import '../../features/settings/presentation/screens/practice_preferences_screen.dart';
import 'app_gate.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const paywall = '/paywall';
  static const session = '/session';
  static const insights = '/insights';
  static const settings = '/settings';
  static const diagnostics = '/diagnostics';
  static const practicePreferences = '/practice-preferences';
  static const trainingRecord = '/training-record';
  static const kana = '/kana';

  /// Path bagan huruf, misalnya `/kana/hiragana`.
  static String kanaFor(KanaScript script) => '$kana/${script.name}';

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
        path: AppRoutes.insights,
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: AppRoutes.trainingRecord,
        builder: (context, state) => const TrainingRecordScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.diagnostics,
        builder: (context, state) => const DiagnosticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.practicePreferences,
        builder: (context, state) => const PracticePreferencesScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.kana}/:script',
        builder: (context, state) => KanaChartScreen(
          script: KanaScript.values.firstWhere(
            (value) => value.name == state.pathParameters['script'],
            orElse: () => KanaScript.hiragana,
          ),
        ),
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
