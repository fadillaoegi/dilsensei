import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:dilsensei/features/onboarding/domain/onboarding_preferences.dart';
import 'package:dilsensei/features/onboarding/presentation/providers/practice_preferences_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

/// Preferensi tersimpan seolah pengguna sudah menuntaskan onboarding.
const _storedPreferences = <String, Object>{
  'dilsensei.onboarding.name': 'Fadil',
  'dilsensei.onboarding.goal': 'travel',
  'dilsensei.onboarding.daily_target_minutes': 10,
  'dilsensei.onboarding.completed': true,
};

Finder _selectedIconOf(String title) {
  return find.descendant(
    of: find.ancestor(of: find.text(title), matching: find.byType(InkWell)),
    matching: find.byIcon(Icons.check_circle_rounded),
  );
}

Future<void> _openPracticePreferences(WidgetTester tester) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(
    buildTestApp(language: AppLanguage.english, useStoredPreferences: true),
  );
  await pumpUntilLoaded(tester);
  await tester.pump();

  await tester.tap(find.byTooltip('Settings'));
  await tester.pumpAndSettle();

  await scrollSettingsTo(tester, 'Goal & daily target');
  await tester.tap(find.text('Goal & daily target'));
  await tester.pumpAndSettle();
}

void main() {
  group('penyunting preferensi', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(_storedPreferences);
    });

    test('mengubah tujuan tanpa menghapus jawaban lain', () async {
      var changedCount = 0;
      final editor = PracticePreferencesEditor(
        dataSource: const OnboardingLocalDataSource(),
        onChanged: () => changedCount++,
      );

      await editor.update(goal: LearningGoal.work);

      final stored = await const OnboardingLocalDataSource().read();
      expect(stored.goal, LearningGoal.work);
      // Nama dan target tidak boleh ikut hilang.
      expect(stored.name, 'Fadil');
      expect(stored.dailyTarget.minutes, 10);
      expect(changedCount, 1);
    });

    test('mengubah target harian tanpa menghapus tujuan', () async {
      final editor = PracticePreferencesEditor(
        dataSource: const OnboardingLocalDataSource(),
        onChanged: () {},
      );

      await editor.update(dailyTarget: DailyTarget.intense);

      final stored = await const OnboardingLocalDataSource().read();
      expect(stored.dailyTarget, DailyTarget.intense);
      expect(stored.goal, LearningGoal.travel);
    });

    test('nama kosong tidak menimpa nama yang sudah ada', () async {
      final editor = PracticePreferencesEditor(
        dataSource: const OnboardingLocalDataSource(),
        onChanged: () {},
      );

      await editor.update(name: '   ');

      expect((await const OnboardingLocalDataSource().read()).name, 'Fadil');
    });
  });

  group('penyunting sebelum onboarding tuntas', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('menolak menulis agar onboarding tidak terlewati', () async {
      var changedCount = 0;
      final editor = PracticePreferencesEditor(
        dataSource: const OnboardingLocalDataSource(),
        onChanged: () => changedCount++,
      );

      await editor.update(goal: LearningGoal.work);

      final stored = await const OnboardingLocalDataSource().read();
      expect(stored.isCompleted, isFalse);
      expect(changedCount, 0);
    });
  });

  group('layar preferensi latihan', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(_storedPreferences);
    });

    testWidgets('menampilkan pilihan yang sedang aktif', (tester) async {
      await _openPracticePreferences(tester);

      expect(find.text('Practice preferences'), findsOneWidget);
      expect(_selectedIconOf('For travel'), findsOneWidget);
      expect(_selectedIconOf('For work'), findsNothing);
    });

    testWidgets('tujuan dapat diganti berkali-kali', (tester) async {
      await _openPracticePreferences(tester);

      await tester.tap(find.text('For work'));
      await tester.pumpAndSettle();
      expect(_selectedIconOf('For work'), findsOneWidget);
      expect(_selectedIconOf('For travel'), findsNothing);

      await tester.tap(find.text('For exams'));
      await tester.pumpAndSettle();
      expect(_selectedIconOf('For exams'), findsOneWidget);
      expect(_selectedIconOf('For work'), findsNothing);

      // Kembali ke pilihan semula juga boleh.
      await tester.tap(find.text('For travel'));
      await tester.pumpAndSettle();
      expect(_selectedIconOf('For travel'), findsOneWidget);
    });

    testWidgets('perubahan tersimpan dan terbaca ulang', (tester) async {
      await _openPracticePreferences(tester);

      await tester.tap(find.text('For work'));
      await tester.pumpAndSettle();

      final stored = await const OnboardingLocalDataSource().read();
      expect(stored.goal, LearningGoal.work);
    });

    testWidgets('perubahan target harian terlihat di Pengaturan', (
      tester,
    ) async {
      await _openPracticePreferences(tester);

      // Target tersimpan 10 menit; ubah ke pilihan lain. Bagian target berada di
      // bawah bagian tujuan, jadi digulir dulu.
      await tester.scrollUntilVisible(
        find.text('Serious'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Serious'));
      await tester.pumpAndSettle();

      final stored = await const OnboardingLocalDataSource().read();
      expect(stored.dailyTarget, DailyTarget.intense);
      expect(stored.dailyTarget.minutes, isNot(10));
    });
  });
}
