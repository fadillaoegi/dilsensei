import 'package:dilsensei/core/theme/app_theme.dart';
import 'package:dilsensei/features/lesson/presentation/providers/progress_controller.dart';
import 'package:dilsensei/features/lesson/presentation/widgets/today_module_card.dart';
import 'package:dilsensei/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:dilsensei/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'dilsensei.onboarding.completed': true,
      'dilsensei.onboarding.name': 'Fadil',
      'dilsensei.onboarding.goal': 'culture',
      'dilsensei.onboarding.daily_target_minutes': 10,
    });
  });

  testWidgets(
    'root app memuat aset mock dengan tema dan bahasa default Inggris',
    (tester) async {
      // Hanya jam yang dikunci; bahasa dan tema sengaja dibiarkan default agar
      // test ini memverifikasi konfigurasi produksi yang sebenarnya.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nowProvider.overrideWithValue(() => DateTime(2026, 9, 1, 12)),
          ],
          child: const DilSenseiApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text('Konnichiwa, Fadil!'), findsOneWidget);
      // Tanpa override apa pun, app memakai default produksi: Bahasa Inggris.
      expect(find.text('Ten minutes between tasks is enough'), findsOneWidget);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.scaffoldBackgroundColor, AppColors.background);
      expect(materialApp.theme?.colorScheme.primary, AppColors.primary);
      expect(materialApp.theme?.colorScheme.secondary, AppColors.secondary);

      // MockLessonRepository menunggu 900ms sebelum data aset tersedia.
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(TodayModuleCard), findsOneWidget);
      expect(find.text('Your roadmap'), findsOneWidget);
    },
  );
}
