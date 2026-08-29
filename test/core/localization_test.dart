import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/features/lesson/data/datasources/lesson_local_data_source.dart';
import 'package:dilsensei/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/lesson_test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('AppLanguage', () {
    test('bahasa Inggris menjadi default aplikasi', () {
      expect(AppLanguage.defaultLanguage, AppLanguage.english);
      expect(AppLanguage.fromCode(null), AppLanguage.english);
      expect(AppLanguage.fromCode('zz'), AppLanguage.english);
      expect(AppLanguage.fromCode('id'), AppLanguage.indonesian);
      expect(AppLanguage.english.locale, const Locale('en'));
    });

    test('pilihan bahasa tersimpan dan terbaca ulang', () async {
      const dataSource = LanguageLocalDataSource();

      expect(await dataSource.read(), AppLanguage.english);

      await dataSource.write(AppLanguage.indonesian);
      expect(await dataSource.read(), AppLanguage.indonesian);
    });
  });

  group('antarmuka dua bahasa', () {
    testWidgets('default Inggris menampilkan teks Inggris di Home', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(language: AppLanguage.english));
      await pumpUntilLoaded(tester);

      expect(find.text('Konnichiwa, Fadil!'), findsOneWidget);
      expect(find.text('Ten minutes between tasks is enough'), findsOneWidget);
      expect(find.text('Your roadmap'), findsOneWidget);
      expect(find.text('Start session (5 min)'), findsOneWidget);

      // Teks Indonesia tidak boleh bocor ke tampilan Inggris.
      expect(find.text('Peta Belajarmu'), findsNothing);
      expect(
        find.text('Sepuluh menit di antara pekerjaan sudah cukup'),
        findsNothing,
      );
    });

    testWidgets('bahasa Indonesia menampilkan teks Indonesia', (tester) async {
      await tester.pumpWidget(buildTestApp(language: AppLanguage.indonesian));
      await pumpUntilLoaded(tester);

      expect(
        find.text('Sepuluh menit di antara pekerjaan sudah cukup'),
        findsOneWidget,
      );
      expect(find.text('Peta Belajarmu'), findsOneWidget);
      expect(find.text('Mulai Sesi (5 Menit)'), findsOneWidget);
    });

    testWidgets('mengganti bahasa di Pengaturan langsung mengubah seluruh UI', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(language: AppLanguage.english));
      await pumpUntilLoaded(tester);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Free plan'), findsOneWidget);
      expect(find.text('Bahasa Indonesia'), findsOneWidget);

      await tester.tap(find.text('Bahasa Indonesia'));
      await tester.pumpAndSettle();

      // Judul dan status ikut berganti tanpa perlu restart.
      expect(find.text('Pengaturan'), findsWidgets);
      expect(find.text('Versi gratis'), findsOneWidget);
      expect(find.text('Free plan'), findsNothing);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Peta Belajarmu'), findsOneWidget);
      expect(find.text('Your roadmap'), findsNothing);
    });

    testWidgets('sesi latihan memakai prompt sesuai bahasa aktif', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          language: AppLanguage.english,
          repository: FakeLessonRepository(drillItems: testBilingualDrillItems),
        ),
      );
      await pumpUntilLoaded(tester);

      await tester.tap(find.text('Start session (5 min)'));
      await tester.pumpAndSettle();

      expect(find.text('BUILD IT IN JAPANESE'), findsOneWidget);
      expect(find.text('I go to school every day.'), findsOneWidget);
      expect(find.text('Saya pergi ke sekolah setiap hari.'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Check'), findsOneWidget);
    });
  });

  group('konten aset', () {
    test('judul modul dan prompt punya versi Inggris yang berbeda', () async {
      const dataSource = LessonLocalDataSource();
      final modules = await dataSource.fetchLessonModules();
      final first = modules.first;

      expect(first.titleFor('id'), 'Sapaan & Aisatsu Dasar');
      expect(first.titleFor('en'), 'Greetings & Basic Aisatsu');

      final items = await dataSource.fetchDrillItems(first.id);
      expect(items.first.promptFor('id'), 'Selamat pagi, Pak Tanaka.');
      expect(items.first.promptFor('en'), 'Good morning, Mr Tanaka.');
    });

    test('bahasa yang tidak dikenal jatuh ke Bahasa Indonesia', () async {
      const dataSource = LessonLocalDataSource();
      final modules = await dataSource.fetchLessonModules();

      expect(modules.first.titleFor('fr'), modules.first.title);
    });
  });
}
