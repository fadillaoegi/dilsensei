import 'package:dilsensei/features/lesson/presentation/widgets/session_summary_view.dart';
import 'package:dilsensei/features/lesson/presentation/widgets/token_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/lesson_test_fixtures.dart';

Future<void> _openMixedSession(WidgetTester tester) async {
  await tester.pumpWidget(
    buildTestApp(
      repository: FakeLessonRepository(drillItems: testMixedDrillItems),
    ),
  );
  await pumpUntilLoaded(tester);

  await tester.tap(find.text('Mulai Sesi (5 Menit)'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('isi partikel menampilkan kalimat berumpang, bukan area susun', (
    tester,
  ) async {
    await _openMixedSession(tester);

    expect(find.text('LENGKAPI PARTIKELNYA'), findsOneWidget);
    expect(find.text('Saya pulang ke rumah.'), findsOneWidget);

    // Area menyusun kalimat tidak relevan untuk tipe pilihan.
    expect(find.byType(AnswerCanvas), findsNothing);
    expect(
      find.text('Ketuk potongan kata untuk menyusun jawaban'),
      findsNothing,
    );

    // Empat pilihan partikel tersedia.
    expect(find.byType(TokenChip), findsNWidgets(4));

    final periksa = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Periksa'),
    );
    expect(periksa.onPressed, isNull, reason: 'belum memilih apa pun');
  });

  testWidgets('memilih partikel yang benar langsung diterima', (tester) async {
    await _openMixedSession(tester);

    await tester.tap(find.text('に'));
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Periksa'));
    await tester.pumpAndSettle();

    expect(find.text('Tepat.'), findsOneWidget);
    // Umpan balik menampilkan kalimat utuh dengan rumpang terisi.
    expect(find.text('わたしは うちに かえります'), findsOneWidget);
  });

  testWidgets('partikel salah menyebut polanya dan mengulang butir', (
    tester,
  ) async {
    await _openMixedSession(tester);

    await tester.tap(find.text('を'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Periksa'));
    await tester.pumpAndSettle();

    expect(
      find.text('Belum tepat — butir ini muncul lagi nanti.'),
      findsOneWidget,
    );
    expect(find.textContaining('Partikel tempat'), findsOneWidget);
  });

  testWidgets('transformasi bentuk menampilkan instruksi dan bentuk dasar', (
    tester,
  ) async {
    await _openMixedSession(tester);

    // Selesaikan butir partikel lebih dulu.
    await tester.tap(find.text('に'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Periksa'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Lanjut'));
    await tester.pumpAndSettle();

    expect(find.text('UBAH KE BENTUK NEGATIF SOPAN'), findsOneWidget);
    expect(find.text('のみます'), findsOneWidget);
    expect(find.text('?'), findsOneWidget, reason: 'jawaban belum dipilih');

    await tester.tap(find.text('のみません'));
    await tester.pump();

    // Jawaban terpilih menggantikan tanda tanya.
    expect(find.text('?'), findsNothing);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Periksa'));
    await tester.pumpAndSettle();

    expect(find.text('Tepat.'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Lihat Hasil'));
    await tester.pumpAndSettle();

    expect(find.byType(SessionSummaryView), findsOneWidget);
    expect(find.text('2/2'), findsOneWidget);
  });
}
