import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/features/lesson/domain/services/day_parts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

Future<void> _pumpHomeAt(
  WidgetTester tester,
  int hour, {
  AppLanguage language = AppLanguage.english,
}) async {
  await tester.pumpWidget(
    buildTestApp(now: DateTime(2026, 9, 1, hour, 30), language: language),
  );
  await pumpUntilLoaded(tester);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('pembagian waktu', () {
    test('pagi mulai 04.00 sampai 10.59', () {
      expect(DayParts.fromHour(4), DayPart.morning);
      expect(DayParts.fromHour(7), DayPart.morning);
      expect(DayParts.fromHour(10), DayPart.morning);
    });

    test('siang mulai 11.00 sampai 14.59', () {
      expect(DayParts.fromHour(11), DayPart.midday);
      expect(DayParts.fromHour(12), DayPart.midday);
      expect(DayParts.fromHour(14), DayPart.midday);
    });

    test('sore mulai 15.00 sampai 17.59', () {
      expect(DayParts.fromHour(15), DayPart.afternoon);
      expect(DayParts.fromHour(17), DayPart.afternoon);
    });

    test('malam mulai 18.00 dan melewati tengah malam sampai 03.59', () {
      expect(DayParts.fromHour(18), DayPart.evening);
      expect(DayParts.fromHour(23), DayPart.evening);
      expect(DayParts.fromHour(0), DayPart.evening);
      expect(DayParts.fromHour(3), DayPart.evening);
    });

    test('setiap batas berpindah tepat pada jamnya', () {
      // Pasangan jam sebelum dan sesudah batas harus berbeda bagian harinya.
      const boundaries = <int>[
        DayParts.morningStart,
        DayParts.middayStart,
        DayParts.afternoonStart,
        DayParts.eveningStart,
      ];

      for (final hour in boundaries) {
        expect(
          DayParts.fromHour(hour),
          isNot(DayParts.fromHour(hour - 1)),
          reason: 'batas pada pukul $hour',
        );
      }
    });

    test('memakai jam dari DateTime yang diberikan', () {
      expect(DayParts.from(DateTime(2026, 9, 1, 5, 30)), DayPart.morning);
      expect(DayParts.from(DateTime(2026, 9, 1, 19, 5)), DayPart.evening);
    });
  });

  group('sapaan di Home', () {
    testWidgets('pagi memakai Ohayou', (tester) async {
      await _pumpHomeAt(tester, 7);

      expect(find.text('Ohayou, Fadil!'), findsOneWidget);
      expect(
        find.text('A short session now sets the tone for the day'),
        findsOneWidget,
      );
    });

    testWidgets('siang memakai Konnichiwa', (tester) async {
      await _pumpHomeAt(tester, 12);

      expect(find.text('Konnichiwa, Fadil!'), findsOneWidget);
      expect(find.text('Ten minutes between tasks is enough'), findsOneWidget);
    });

    testWidgets('sore tetap Konnichiwa tapi subjudulnya berbeda', (
      tester,
    ) async {
      await _pumpHomeAt(tester, 16);

      expect(find.text('Konnichiwa, Fadil!'), findsOneWidget);
      expect(
        find.text('Beat the afternoon slump with one quick drill'),
        findsOneWidget,
      );
      expect(find.text('Ten minutes between tasks is enough'), findsNothing);
    });

    testWidgets('malam memakai Konbanwa', (tester) async {
      await _pumpHomeAt(tester, 21);

      expect(find.text('Konbanwa, Fadil!'), findsOneWidget);
      expect(
        find.text('Close the day by locking in what you practised'),
        findsOneWidget,
      );
    });

    testWidgets('lewat tengah malam masih dianggap malam', (tester) async {
      await _pumpHomeAt(tester, 2);

      expect(find.text('Konbanwa, Fadil!'), findsOneWidget);
    });

    testWidgets('subjudul mengikuti bahasa yang dipilih', (tester) async {
      await _pumpHomeAt(tester, 7, language: AppLanguage.indonesian);

      expect(find.text('Ohayou, Fadil!'), findsOneWidget);
      expect(
        find.text('Sesi singkat sekarang menentukan ritme harimu'),
        findsOneWidget,
      );
    });
  });
}
