import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/features/lesson/domain/services/reminder_scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

/// Penjadwal palsu: mencatat panggilan tanpa menyentuh perangkat.
class FakeReminderScheduler implements ReminderScheduler {
  FakeReminderScheduler({this.permissionGranted = true});

  final bool permissionGranted;

  final List<ReminderContent> scheduled = <ReminderContent>[];
  int cancelCount = 0;
  int permissionRequests = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<void> schedule(ReminderContent content) async {
    scheduled.add(content);
  }

  @override
  Future<void> cancel() async {
    cancelCount++;
  }
}

/// Progres dengan satu pola yang sering salah, agar pesannya spesifik.
const _weakProgress =
    '{"streak_days":3,"last_session_date":"2026-08-31",'
    '"total_sessions":3,"best_reflex_score":70,"sessions_today":0,'
    '"pattern_events":['
    '{"pattern_id":"particle_place","date":"2026-08-31","was_correct":false,"response_ms":6000},'
    '{"pattern_id":"particle_place","date":"2026-08-31","was_correct":false,"response_ms":6000},'
    '{"pattern_id":"particle_place","date":"2026-08-31","was_correct":false,"response_ms":6000}'
    '],"recent_sessions":[]}';

Future<void> _openSettings(
  WidgetTester tester, {
  required FakeReminderScheduler scheduler,
  AppLanguage language = AppLanguage.english,
  String? storedProgress,
}) async {
  final stored = <String, Object>{};
  if (storedProgress != null) {
    stored['dilsensei.learning_progress.v1'] = storedProgress;
  }
  SharedPreferences.setMockInitialValues(stored);

  usePhoneViewport(tester);
  await tester.pumpWidget(
    buildTestApp(
      now: DateTime(2026, 9, 1, 12),
      language: language,
      reminderScheduler: scheduler,
    ),
  );
  await pumpUntilLoaded(tester);
  await tester.pump();

  await tester.tap(
    find.byTooltip(language == AppLanguage.english ? 'Settings' : 'Pengaturan'),
  );
  await tester.pumpAndSettle();

  // ListView Pengaturan bersifat lazy, jadi bagian pengingat harus digulir ke
  // layar dulu. Tanpa ini test ikut rusak setiap kali ada bagian baru
  // ditambahkan di atasnya.
  await tester.scrollUntilVisible(
    find.text(
      language == AppLanguage.english ? 'DAILY REMINDER' : 'PENGINGAT HARIAN',
    ),
    150,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pengingat mati secara bawaan dan pemilih jam disembunyikan', (
    tester,
  ) async {
    final scheduler = FakeReminderScheduler();
    await _openSettings(tester, scheduler: scheduler);

    expect(find.text('DAILY REMINDER'), findsOneWidget);
    expect(find.text('Remind me to practise'), findsOneWidget);
    expect(find.text('Reminder time'), findsNothing);
    expect(scheduler.scheduled, isEmpty);
  });

  testWidgets('menyalakan pengingat meminta izin dan menjadwalkan pesan pola', (
    tester,
  ) async {
    final scheduler = FakeReminderScheduler();
    await _openSettings(
      tester,
      scheduler: scheduler,
      storedProgress: _weakProgress,
    );

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(scheduler.permissionRequests, 1);
    expect(scheduler.scheduled, hasLength(1));

    final content = scheduler.scheduled.single;
    expect(content.title, 'Place particle is still slipping');
    expect(content.scheduledFor, DateTime(2026, 9, 1, 19));

    // Pemilih jam muncul setelah pengingat aktif.
    expect(find.text('Reminder time'), findsOneWidget);
    expect(find.text('Every day at 19:00'), findsOneWidget);
  });

  testWidgets('izin ditolak memberi tahu pengguna dan tidak menjadwalkan', (
    tester,
  ) async {
    final scheduler = FakeReminderScheduler(permissionGranted: false);
    await _openSettings(tester, scheduler: scheduler);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(scheduler.scheduled, isEmpty);
    expect(find.textContaining('Notifications are turned off'), findsOneWidget);
  });

  testWidgets('mematikan pengingat membatalkan jadwalnya', (tester) async {
    final scheduler = FakeReminderScheduler();
    await _openSettings(
      tester,
      scheduler: scheduler,
      storedProgress: _weakProgress,
    );

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(scheduler.cancelCount, greaterThanOrEqualTo(1));
    expect(find.text('Reminder time'), findsNothing);
  });

  testWidgets('isi pengingat mengikuti bahasa yang dipilih', (tester) async {
    final scheduler = FakeReminderScheduler();
    await _openSettings(
      tester,
      scheduler: scheduler,
      language: AppLanguage.indonesian,
      storedProgress: _weakProgress,
    );

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(
      scheduler.scheduled.single.title,
      'Partikel tempat masih sering meleset',
    );
  });
}
