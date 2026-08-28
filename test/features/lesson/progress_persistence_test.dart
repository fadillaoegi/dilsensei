import 'package:dilsensei/features/lesson/presentation/widgets/session_summary_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

final _now = DateTime(2026, 9, 1, 9, 0);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('streak mulai dari nol lalu jadi satu setelah sesi tuntas', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(now: _now));
    await pumpUntilLoaded(tester);

    expect(find.text('0'), findsOneWidget, reason: 'pengguna baru');

    await tester.tap(find.text('Mulai Sesi (5 Menit)'));
    await tester.pumpAndSettle();

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

    expect(find.byType(SessionSummaryView), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Selesai'));
    await tester.pumpAndSettle();

    expect(find.text('Konnichiwa, Fadil!'), findsOneWidget);
    expect(find.text('1'), findsOneWidget, reason: 'streak tercatat');
  });

  testWidgets('progres tersimpan dibaca ulang saat app dibuka kembali', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'dilsensei.learning_progress.v1':
          '{"streak_days":4,"last_session_date":"2026-08-31",'
          '"total_sessions":4,"best_reflex_score":72,'
          '"pattern_miss_counts":{"particle_place":3}}',
    });

    await tester.pumpWidget(buildTestApp(now: _now));
    await pumpUntilLoaded(tester);
    await tester.pump();

    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('streak yang terputus ditampilkan sebagai nol', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'dilsensei.learning_progress.v1':
          '{"streak_days":9,"last_session_date":"2026-08-20",'
          '"total_sessions":9,"best_reflex_score":91,'
          '"pattern_miss_counts":{}}',
    });

    await tester.pumpWidget(buildTestApp(now: _now));
    await pumpUntilLoaded(tester);
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('9'), findsNothing);
  });
}
