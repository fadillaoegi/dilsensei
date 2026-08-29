import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/core/theme/app_theme.dart';
import 'package:dilsensei/core/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

/// Warna latar Scaffold yang benar-benar dirender.
Color _scaffoldColor(WidgetTester tester) {
  final scaffold = tester.widget<Material>(
    find
        .descendant(
          of: find.byType(Scaffold).first,
          matching: find.byType(Material),
        )
        .first,
  );

  return scaffold.color!;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Home dirender dengan palet gelap saat mode gelap dipilih', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(language: AppLanguage.english, themeMode: AppThemeMode.dark),
    );
    await pumpUntilLoaded(tester);

    final context = tester.element(find.byType(Scaffold).first);

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(context.palette, AppPalette.dark);
    expect(_scaffoldColor(tester), AppPalette.dark.surface);
  });

  testWidgets('Home tetap terang saat mode terang dipilih', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(
        language: AppLanguage.english,
        themeMode: AppThemeMode.light,
      ),
    );
    await pumpUntilLoaded(tester);

    final context = tester.element(find.byType(Scaffold).first);

    expect(Theme.of(context).brightness, Brightness.light);
    expect(context.palette, AppPalette.light);
    expect(_scaffoldColor(tester), AppPalette.light.surface);
  });

  testWidgets('teks Home memakai warna terang saat mode gelap', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(language: AppLanguage.english, themeMode: AppThemeMode.dark),
    );
    await pumpUntilLoaded(tester);

    // Sapaan Home dirender lewat textTheme, jadi warnanya harus ikut palet.
    final context = tester.element(find.byType(Scaffold).first);
    final heading = Theme.of(context).textTheme.headlineMedium;

    expect(heading?.color, AppPalette.dark.textPrimary);
    expect(heading?.color, isNot(AppPalette.light.textPrimary));
  });

  testWidgets('mengganti tema di Pengaturan langsung mengubah tampilan', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(
        language: AppLanguage.english,
        themeMode: AppThemeMode.light,
      ),
    );
    await pumpUntilLoaded(tester);
    await tester.pump();

    expect(_scaffoldColor(tester), AppPalette.light.surface);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('APPEARANCE'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(_scaffoldColor(tester), AppPalette.dark.surface);
  });

  testWidgets('pilihan tema ditandai dan hanya satu yang aktif', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(
        language: AppLanguage.english,
        themeMode: AppThemeMode.system,
      ),
    );
    await pumpUntilLoaded(tester);
    await tester.pump();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('APPEARANCE'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Match device'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    // Hanya pilihan aktif yang memakai ikon terpilih.
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
  });

  testWidgets('pemilih tema ikut diterjemahkan', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(
        language: AppLanguage.indonesian,
        themeMode: AppThemeMode.light,
      ),
    );
    await pumpUntilLoaded(tester);
    await tester.pump();

    await tester.tap(find.byTooltip('Pengaturan'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('TAMPILAN'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Ikuti perangkat'), findsOneWidget);
    expect(find.text('Gelap'), findsOneWidget);
    expect(find.text('Dark'), findsNothing);
  });
}
