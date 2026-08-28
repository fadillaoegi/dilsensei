import 'package:dilsensei/features/lesson/presentation/screens/drill_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/lesson_test_fixtures.dart';

/// Membuka sesi lewat alur nyata: tap modul gratis pada Hero Card.
Future<void> _openSession(WidgetTester tester) async {
  await tester.pumpWidget(buildTestApp());
  await pumpUntilLoaded(tester);

  await tester.tap(find.text('Mulai Sesi (5 Menit)'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sesi menampilkan prompt pertama dan bank potongan kata', (
    tester,
  ) async {
    await _openSession(tester);

    expect(find.byType(DrillSessionScreen), findsOneWidget);
    expect(find.text('Saya pergi ke sekolah setiap hari.'), findsOneWidget);
    expect(find.text('0/2'), findsOneWidget);
    expect(
      find.text('Ketuk potongan kata untuk menyusun jawaban'),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Periksa'), findsOneWidget);
  });

  testWidgets('tombol Periksa nonaktif sampai jawaban lengkap', (tester) async {
    await _openSession(tester);

    final periksa = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Periksa'),
    );
    expect(periksa.onPressed, isNull);

    await tester.tap(find.text('まいにち'));
    await tester.pump();

    final masihKurang = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Periksa'),
    );
    expect(masihKurang.onPressed, isNull);
  });

  testWidgets('jawaban benar memberi umpan balik dan memajukan progres', (
    tester,
  ) async {
    await _openSession(tester);

    for (final token in ['まいにち', 'がっこう', 'に', 'いきます']) {
      await tester.tap(find.text(token));
      await tester.pump();
    }

    await tester.tap(find.widgetWithText(ElevatedButton, 'Periksa'));
    await tester.pumpAndSettle();

    expect(find.text('Tepat.'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Lanjut'));
    await tester.pumpAndSettle();

    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('Saya tidak minum kopi.'), findsOneWidget);
  });

  testWidgets('jawaban salah mengulang butir dan menyebut pola tata bahasa', (
    tester,
  ) async {
    await _openSession(tester);

    // Urutan sengaja dibuat salah dengan memakai partikel pengecoh.
    for (final token in ['まいにち', 'がっこう', 'を', 'いきます']) {
      await tester.tap(find.text(token));
      await tester.pump();
    }

    await tester.tap(find.widgetWithText(ElevatedButton, 'Periksa'));
    await tester.pumpAndSettle();

    expect(
      find.text('Belum tepat — butir ini muncul lagi nanti.'),
      findsOneWidget,
    );
    expect(find.textContaining('Partikel tempat'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Lanjut'));
    await tester.pumpAndSettle();

    // Progres tidak bertambah karena butir belum tuntas.
    expect(find.text('0/2'), findsOneWidget);
  });

  testWidgets('menyelesaikan seluruh butir menampilkan skor refleks', (
    tester,
  ) async {
    await _openSession(tester);

    for (final answer in [
      ['まいにち', 'がっこう', 'に', 'いきます'],
      ['コーヒー', 'を', 'のみません'],
    ]) {
      for (final token in answer) {
        await tester.tap(find.text(token));
        await tester.pump();
      }
      await tester.tap(find.widgetWithText(ElevatedButton, 'Periksa'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ElevatedButton &&
              widget.child is Text &&
              ((widget.child! as Text).data == 'Lanjut' ||
                  (widget.child! as Text).data == 'Lihat Hasil'),
        ),
      );
      await tester.pumpAndSettle();
    }

    expect(find.text('Sesi selesai'), findsOneWidget);
    expect(find.text('skor refleks'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Selesai'), findsOneWidget);
  });
}
