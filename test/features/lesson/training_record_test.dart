import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/features/lesson/presentation/screens/training_record_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

final _now = DateTime(2026, 9, 10, 12);

/// Progres yang sudah menuntaskan ketiga modul fixture dengan performa bagus.
const _completedProgress =
    '{"streak_days":3,"last_session_date":"2026-09-10",'
    '"total_sessions":3,"best_reflex_score":90,"sessions_today":1,'
    '"completed_module_ids":["free-1","free-2","premium-1"],'
    '"pattern_events":['
    '{"pattern_id":"particle_place","date":"2026-09-10","was_correct":true,"response_ms":2200},'
    '{"pattern_id":"particle_place","date":"2026-09-09","was_correct":true,"response_ms":2400},'
    '{"pattern_id":"past_form","date":"2026-09-10","was_correct":true,"response_ms":2600}'
    '],'
    '"recent_sessions":['
    '{"date":"2026-09-10","reflex_score":90,"first_try_correct":8,"planned_count":8},'
    '{"date":"2026-09-09","reflex_score":85,"first_try_correct":8,"planned_count":8}'
    ']}';

Future<void> _openRecord(
  WidgetTester tester, {
  String? storedProgress,
  AppLanguage language = AppLanguage.english,
}) async {
  final stored = <String, Object>{};
  if (storedProgress != null) {
    stored['dilsensei.learning_progress.v1'] = storedProgress;
  }
  SharedPreferences.setMockInitialValues(stored);

  usePhoneViewport(tester);
  await tester.pumpWidget(buildTestApp(now: _now, language: language));
  await pumpUntilLoaded(tester);
  await tester.pump();

  await tester.tap(
    find.byTooltip(language == AppLanguage.english ? 'Settings' : 'Pengaturan'),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Training Record'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('terkunci sebelum semua modul selesai, dengan progresnya', (
    tester,
  ) async {
    await _openRecord(tester);

    expect(find.byType(TrainingRecordScreen), findsOneWidget);
    expect(find.text('Your record is not ready yet'), findsOneWidget);
    expect(find.textContaining('0 of 3 modules done'), findsOneWidget);
  });

  testWidgets('terbuka setelah semua modul selesai dan menampilkan rincian', (
    tester,
  ) async {
    await _openRecord(tester, storedProgress: _completedProgress);

    expect(find.text('Your record is not ready yet'), findsNothing);
    expect(find.text('DILSENSEI TRAINING RECORD'), findsOneWidget);
    expect(find.text('This record certifies that'), findsOneWidget);
    expect(find.text('Fadil'), findsOneWidget);
    expect(
      find.textContaining('completed all 3 grammar reflex modules'),
      findsOneWidget,
    );

    // Empat komponen skor beserta bobotnya; berada di bawah lipatan.
    await tester.scrollUntilVisible(
      find.textContaining('weight 5%'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('weight 40%'), findsOneWidget);
    expect(find.textContaining('weight 30%'), findsOneWidget);
    expect(find.textContaining('weight 25%'), findsOneWidget);
    expect(find.textContaining('weight 5%'), findsOneWidget);

    // Penegasan bahwa ini bukan kualifikasi resmi.
    await tester.scrollUntilVisible(
      find.textContaining('not an official language qualification'),
      -240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('not an official language qualification'),
      findsOneWidget,
    );
  });

  testWidgets('isi sertifikat tetap Inggris meski app berbahasa Indonesia', (
    tester,
  ) async {
    await _openRecord(
      tester,
      storedProgress: _completedProgress,
      language: AppLanguage.indonesian,
    );

    expect(find.text('DILSENSEI TRAINING RECORD'), findsOneWidget);
    expect(find.text('This record certifies that'), findsOneWidget);
    expect(find.text('How the score is built'), findsOneWidget);
  });

  testWidgets('tombol dev menandai semua modul selesai lalu membuka record', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(now: _now, language: AppLanguage.english),
    );
    await pumpUntilLoaded(tester);
    await tester.pump();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('DEV: Complete all modules'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('DEV: Complete all modules'));
    await tester.pumpAndSettle();

    expect(find.textContaining('modul ditandai selesai'), findsOneWidget);

    // Kembali ke atas daftar Pengaturan, lalu buka Training Record. Jaraknya
    // dibuat berlebih dengan sengaja supaya test tidak rusak setiap kali ada
    // bagian pengaturan baru ditambahkan.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();

    final recordTile = find.text('Training Record');
    expect(recordTile, findsOneWidget);
    await tester.ensureVisible(recordTile);
    await tester.pumpAndSettle();
    await tester.tap(recordTile);
    await tester.pumpAndSettle();

    expect(find.text('DILSENSEI TRAINING RECORD'), findsOneWidget);
    expect(find.text('Your record is not ready yet'), findsNothing);
  });
}
