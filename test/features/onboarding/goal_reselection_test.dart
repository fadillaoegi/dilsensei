import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

/// Ikon terpilih pada kartu yang memuat [title].
Finder _selectedIconOf(String title) {
  return find.descendant(
    of: find.ancestor(of: find.text(title), matching: find.byType(InkWell)),
    matching: find.byIcon(Icons.check_circle_rounded),
  );
}

Future<void> _openGoalStep(WidgetTester tester) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(
    buildTestApp(language: AppLanguage.english, skipOnboarding: false),
  );
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField), 'Fadil');
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('pilihan tujuan dapat diganti setelah dipilih', (tester) async {
    await _openGoalStep(tester);

    expect(find.text('For work'), findsOneWidget);
    expect(find.text('For travel'), findsOneWidget);

    await tester.tap(find.text('For work'));
    await tester.pumpAndSettle();

    expect(_selectedIconOf('For work'), findsOneWidget);
    expect(_selectedIconOf('For travel'), findsNothing);

    // Mengganti pilihan harus berhasil, dan hanya satu yang aktif.
    await tester.tap(find.text('For travel'));
    await tester.pumpAndSettle();

    expect(_selectedIconOf('For travel'), findsOneWidget);
    expect(_selectedIconOf('For work'), findsNothing);

    // Berganti berkali-kali tetap boleh.
    await tester.tap(find.text('For exams'));
    await tester.pumpAndSettle();

    expect(_selectedIconOf('For exams'), findsOneWidget);
    expect(_selectedIconOf('For travel'), findsNothing);
  });

  testWidgets('pilihan target harian juga dapat diganti', (tester) async {
    await _openGoalStep(tester);

    await tester.tap(find.text('For work'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Langkah ketiga: target harian.
    final options = find.byType(InkWell);
    expect(options, findsWidgets);

    final firstLabel = tester
        .widgetList<Text>(
          find.descendant(of: options.first, matching: find.byType(Text)),
        )
        .first
        .data!;

    await tester.tap(find.text(firstLabel));
    await tester.pumpAndSettle();

    expect(_selectedIconOf(firstLabel), findsOneWidget);
  });

  testWidgets('kembali ke langkah sebelumnya mempertahankan pilihan', (
    tester,
  ) async {
    await _openGoalStep(tester);

    await tester.tap(find.text('For travel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    // Pilihan sebelumnya masih aktif, dan masih bisa diganti.
    expect(_selectedIconOf('For travel'), findsOneWidget);

    await tester.tap(find.text('For anime & culture'));
    await tester.pumpAndSettle();

    expect(_selectedIconOf('For anime & culture'), findsOneWidget);
    expect(_selectedIconOf('For travel'), findsNothing);
  });
}
