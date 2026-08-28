import 'package:dilsensei/features/lesson/presentation/widgets/session_summary_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/lesson_test_fixtures.dart';

/// Menyelesaikan seluruh butir sesi; [wrongFirst] membuat butir pertama salah
/// dulu agar ada pola lemah yang tercatat.
Future<void> _finishSession(
  WidgetTester tester, {
  required bool wrongFirst,
}) async {
  await tester.pumpWidget(buildTestApp());
  await pumpUntilLoaded(tester);
  await tester.tap(find.text('Mulai Sesi (5 Menit)'));
  await tester.pumpAndSettle();

  if (wrongFirst) {
    for (final token in ['まいにち', 'がっこう', 'を', 'いきます']) {
      await tester.tap(find.text(token));
      await tester.pump();
    }
    await tester.tap(find.widgetWithText(ElevatedButton, 'Periksa'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Lanjut'));
    await tester.pumpAndSettle();
  }

  // Sisa butir dijawab benar sampai antrean habis.
  const answers = <List<String>>[
    ['コーヒー', 'を', 'のみません'],
    ['まいにち', 'がっこう', 'に', 'いきます'],
  ];

  while (find.text('Sesi selesai').evaluate().isEmpty) {
    var answered = false;
    for (final answer in answers) {
      if (find.text('Periksa').evaluate().isEmpty) break;

      final canAnswer = answer.every(
        (token) => find.text(token).evaluate().isNotEmpty,
      );
      if (!canAnswer) continue;

      for (final token in answer) {
        await tester.tap(find.text(token).first);
        await tester.pump();
      }
      final periksa = find.widgetWithText(ElevatedButton, 'Periksa');
      if (tester.widget<ElevatedButton>(periksa).onPressed == null) {
        // Kombinasi tidak cocok untuk butir ini; bersihkan lalu coba berikutnya.
        await tester.tap(find.widgetWithText(TextButton, 'Hapus'));
        await tester.pump();
        continue;
      }

      await tester.tap(periksa);
      await tester.pumpAndSettle();
      final lanjut = find.byWidgetPredicate(
        (widget) =>
            widget is ElevatedButton &&
            widget.child is Text &&
            ((widget.child! as Text).data == 'Lanjut' ||
                (widget.child! as Text).data == 'Lihat Hasil'),
      );
      await tester.tap(lanjut);
      await tester.pumpAndSettle();
      answered = true;
      break;
    }

    if (!answered) break;
  }
}

void main() {
  testWidgets('sesi tanpa kesalahan tidak menawarkan latihan pola lemah', (
    tester,
  ) async {
    await _finishSession(tester, wrongFirst: false);

    expect(find.byType(SessionSummaryView), findsOneWidget);
    expect(find.text('Sesi selesai'), findsOneWidget);
    expect(find.text('skor refleks'), findsOneWidget);
    expect(find.text('Benar sekali coba'), findsOneWidget);
    expect(find.text('2/2'), findsOneWidget);
    expect(find.text('Bersih.'), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Latih pola lemah sekarang'),
      findsNothing,
    );
    expect(find.widgetWithText(ElevatedButton, 'Selesai'), findsOneWidget);
  });

  testWidgets('sesi dengan kesalahan menampilkan peta pola dan tombol latih', (
    tester,
  ) async {
    await _finishSession(tester, wrongFirst: true);

    expect(find.text('Pola yang belum jadi refleks'), findsOneWidget);
    expect(find.text('Partikel tempat'), findsOneWidget);
    expect(find.text('Urutan keterangan waktu'), findsOneWidget);
    expect(find.text('1x'), findsNWidgets(2));
    expect(find.text('1/2'), findsOneWidget);

    final drillButton = find.widgetWithText(
      ElevatedButton,
      'Latih pola lemah sekarang',
    );
    expect(drillButton, findsOneWidget);

    await tester.tap(drillButton);
    await tester.pumpAndSettle();

    // Sesi baru hanya berisi butir yang menguji pola lemah tersebut.
    expect(find.byType(SessionSummaryView), findsNothing);
    expect(find.text('Saya pergi ke sekolah setiap hari.'), findsOneWidget);
    expect(find.text('0/1'), findsOneWidget);
  });
}
