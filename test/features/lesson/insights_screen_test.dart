import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/features/lesson/presentation/screens/insights_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

final _now = DateTime(2026, 9, 1, 12);

/// Membangun JSON progres berisi peristiwa pola.
String _progressJson(String events) {
  return '{"streak_days":3,"last_session_date":"2026-09-01",'
      '"total_sessions":4,"best_reflex_score":80,"sessions_today":1,'
      '"pattern_events":[$events],"recent_sessions":[]}';
}

String _event(
  String patternId, {
  required bool correct,
  required int responseMs,
  String date = '2026-09-01',
}) {
  return '{"pattern_id":"$patternId","date":"$date",'
      '"was_correct":$correct,"response_ms":$responseMs}';
}

Future<void> _openInsights(
  WidgetTester tester, {
  required String events,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'dilsensei.learning_progress.v1': _progressJson(events),
  });

  await tester.pumpWidget(
    buildTestApp(
      now: _now,
      language: AppLanguage.english,
      subscriptionService: FakeSubscriptionService(isPremium: true),
    ),
  );
  await pumpUntilLoaded(tester);
  await tester.pump();

  await tester.tap(find.byTooltip('Weak spots'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pola yang selalu benar tapi lambat muncul sebagai lambat', (
    tester,
  ) async {
    final slow = List<String>.generate(
      8,
      (_) => _event('particle_place', correct: true, responseMs: 11000),
    ).join(',');

    await _openInsights(tester, events: slow);

    expect(find.byType(InsightsScreen), findsOneWidget);
    expect(find.text('Place particle'), findsOneWidget);
    // Alasannya kecepatan, bukan kesalahan.
    expect(find.text('8 slow'), findsOneWidget);
    expect(find.textContaining('wrong'), findsNothing);
  });

  testWidgets('pola yang sering salah muncul dengan jumlah kesalahannya', (
    tester,
  ) async {
    final wrong = List<String>.generate(
      5,
      (_) => _event('past_form', correct: false, responseMs: 6000),
    ).join(',');

    await _openInsights(tester, events: wrong);

    expect(find.text('Past form'), findsOneWidget);
    expect(find.text('5 wrong'), findsOneWidget);
  });

  testWidgets('pola cepat dan benar masuk daftar sudah jadi refleks', (
    tester,
  ) async {
    final solid = List<String>.generate(
      8,
      (_) => _event('polite_form', correct: true, responseMs: 2000),
    ).join(',');

    await _openInsights(tester, events: solid);

    expect(find.text('Already reflex'), findsOneWidget);
    expect(find.text('Polite form'), findsOneWidget);
    expect(find.text('Solid'), findsOneWidget);
    // Tidak ada pola yang perlu dilatih.
    expect(
      find.text(
        'No pattern has gone wrong yet. Finish a few more sessions to see the map.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('kesalahan lama tidak lagi ditandai perlu dilatih', (
    tester,
  ) async {
    // Lima kesalahan, tapi semuanya 28 hari lalu: empat kali umur paruh.
    final stale = List<String>.generate(
      5,
      (_) => _event(
        'counter_word',
        correct: false,
        responseMs: 6000,
        date: '2026-08-04',
      ),
    ).join(',');

    await _openInsights(tester, events: stale);

    expect(find.text('Already reflex'), findsOneWidget);
    expect(find.text('Counter word'), findsOneWidget);
  });
}
