import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/features/kana/domain/kana_chart.dart';
import 'package:dilsensei/features/kana/presentation/screens/kana_chart_screen.dart';
import 'package:dilsensei/features/monetization/presentation/screens/paywall_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

/// Jumlah baku tiap bagian bagan kana.
const _baseCount = 46;
const _voicedCount = 25;
const _combinedCount = 33;

Future<void> _pumpHome(
  WidgetTester tester, {
  AppLanguage language = AppLanguage.english,
}) async {
  await tester.pumpWidget(buildTestApp(language: language));
  await pumpUntilLoaded(tester);
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('data bagan', () {
    for (final script in KanaScript.values) {
      test('${script.name} punya jumlah huruf yang benar', () {
        final sections = KanaChart.sectionsFor(script);
        final byKind = <KanaSectionKind, int>{
          for (final section in sections) section.kind: section.cells.length,
        };

        expect(byKind[KanaSectionKind.base], _baseCount);
        expect(byKind[KanaSectionKind.voiced], _voicedCount);
        expect(byKind[KanaSectionKind.combined], _combinedCount);
      });

      test('${script.name} tidak punya huruf duplikat atau romaji kosong', () {
        final cells = KanaChart.sectionsFor(
          script,
        ).expand((section) => section.cells).toList();

        final characters = cells.map((cell) => cell.character).toList();
        expect(
          characters.toSet().length,
          characters.length,
          reason: 'huruf tidak boleh muncul dua kali',
        );

        for (final cell in cells) {
          expect(cell.character.trim(), isNotEmpty);
          expect(cell.romaji.trim(), isNotEmpty, reason: cell.character);
          expect(
            cell.romaji,
            matches(RegExp(r'^[a-z]+$')),
            reason: 'romaji ${cell.romaji} harus huruf kecil tanpa spasi',
          );
        }
      });
    }

    test('hiragana dan katakana memakai romaji yang sama persis', () {
      List<String> romajiOf(KanaScript script) => KanaChart.sectionsFor(
        script,
      ).expand((section) => section.cells).map((cell) => cell.romaji).toList();

      expect(romajiOf(KanaScript.hiragana), romajiOf(KanaScript.katakana));
    });

    test('kedua aksara tidak berbagi huruf yang sama', () {
      Set<String> charsOf(KanaScript script) => KanaChart.sectionsFor(script)
          .expand((section) => section.cells)
          .map((cell) => cell.character)
          .toSet();

      expect(
        charsOf(KanaScript.hiragana).intersection(charsOf(KanaScript.katakana)),
        isEmpty,
      );
    });
  });

  group('alur dari Home', () {
    testWidgets('pintu masuk bagan tampil dengan penanda gratis', (
      tester,
    ) async {
      await _pumpHome(tester);

      expect(find.text('Refresh the letters first'), findsOneWidget);
      expect(find.text('FREE'), findsOneWidget);
      expect(find.text('Hiragana'), findsOneWidget);
      expect(find.text('Katakana'), findsOneWidget);
      // 46 + 25 + 33 huruf untuk masing-masing aksara.
      expect(find.text('104 letters'), findsNWidgets(2));
    });

    testWidgets('membuka bagan hiragana tanpa melewati paywall', (
      tester,
    ) async {
      await _pumpHome(tester);

      await tester.tap(find.text('Hiragana'));
      await tester.pumpAndSettle();

      expect(find.byType(KanaChartScreen), findsOneWidget);
      expect(
        find.byType(PaywallScreen),
        findsNothing,
        reason: 'bagan huruf harus gratis',
      );

      // Penjelasan penggunaan dan huruf pertama terlihat.
      expect(find.text('When do you use it?'), findsOneWidget);
      expect(
        find.textContaining('Hiragana is the base script'),
        findsOneWidget,
      );
      expect(find.text('あ'), findsOneWidget);
      expect(find.text('Gojūon · 46 base letters'), findsOneWidget);
    });

    testWidgets('bagan katakana menampilkan huruf dan penjelasannya sendiri', (
      tester,
    ) async {
      await _pumpHome(tester);

      await tester.tap(find.text('Katakana'));
      await tester.pumpAndSettle();

      expect(find.text('ア'), findsOneWidget);
      expect(find.textContaining('Katakana marks words'), findsOneWidget);
      expect(find.text('あ'), findsNothing);
    });

    testWidgets('penjelasan mengikuti bahasa yang dipilih', (tester) async {
      await _pumpHome(tester, language: AppLanguage.indonesian);

      expect(find.text('Segarkan hurufnya dulu'), findsOneWidget);
      expect(find.text('GRATIS'), findsOneWidget);

      await tester.tap(find.text('Hiragana'));
      await tester.pumpAndSettle();

      expect(find.text('Dipakai kapan?'), findsOneWidget);
      expect(
        find.textContaining('Hiragana adalah aksara dasar'),
        findsOneWidget,
      );
    });
  });
}
