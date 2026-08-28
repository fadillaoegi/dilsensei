import 'package:dilsensei/core/theme/app_theme.dart';
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

  testWidgets('root app memuat data aset mock dengan tema Organic Minimalism', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: DilSenseiApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.text('Konnichiwa, Fadil!'), findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.scaffoldBackgroundColor, AppColors.background);
    expect(materialApp.theme?.colorScheme.primary, AppColors.primary);
    expect(materialApp.theme?.colorScheme.secondary, AppColors.secondary);

    // MockLessonRepository menunggu 900ms sebelum data aset tersedia.
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(TodayModuleCard), findsOneWidget);
    expect(find.text('Peta Belajarmu'), findsOneWidget);
  });
}
