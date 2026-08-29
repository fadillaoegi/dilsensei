import 'package:dilsensei/features/lesson/data/datasources/progress_local_data_source.dart';
import 'package:dilsensei/features/lesson/domain/entities/learning_progress.dart';
import 'package:dilsensei/features/lesson/domain/entities/pattern_event.dart';
import 'package:dilsensei/features/lesson/domain/services/pattern_insights.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'dilsensei.learning_progress.v1';
final _today = DateTime(2026, 9, 1);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const dataSource = ProgressLocalDataSource();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('peristiwa pola bertahan setelah ditulis dan dibaca ulang', () async {
    final progress = LearningProgress(
      streakDays: 2,
      lastSessionDate: _today,
      totalSessions: 2,
      bestReflexScore: 88,
      sessionsToday: 1,
      recentSessions: const <SessionRecord>[],
      completedModuleIds: const <String>{'m1', 'm2'},
      patternEvents: <PatternEvent>[
        PatternEvent(
          patternId: 'particle_place',
          date: _today,
          wasCorrect: false,
          responseTime: const Duration(milliseconds: 5400),
        ),
        PatternEvent(
          patternId: 'past_form',
          date: DateTime(2026, 8, 30),
          wasCorrect: true,
          responseTime: const Duration(milliseconds: 9100),
        ),
      ],
    );

    await dataSource.write(progress);
    final restored = await dataSource.read();

    expect(restored.patternEvents.length, 2);

    final first = restored.patternEvents.first;
    expect(first.patternId, 'particle_place');
    expect(first.date, _today);
    expect(first.wasCorrect, isFalse);
    expect(first.responseTime, const Duration(milliseconds: 5400));

    final second = restored.patternEvents.last;
    expect(second.wasCorrect, isTrue);
    expect(second.responseTime, const Duration(milliseconds: 9100));
    expect(restored.completedModuleIds, <String>{'m1', 'm2'});
  });

  test('data format lama diubah menjadi peristiwa bertanggal', () async {
    // Format sebelum peta kelemahan memakai peristiwa: hanya hitungan.
    SharedPreferences.setMockInitialValues(<String, Object>{
      _key:
          '{"streak_days":3,"last_session_date":"2026-09-01",'
          '"total_sessions":3,"best_reflex_score":70,"sessions_today":1,'
          '"pattern_miss_counts":{"particle_place":3,"past_form":1},'
          '"recent_sessions":[]}',
    });

    final restored = await dataSource.read();

    expect(
      restored.patternEvents.length,
      4,
      reason: 'tiga kesalahan partikel tempat dan satu bentuk lampau',
    );
    expect(restored.patternEvents.every((event) => !event.wasCorrect), isTrue);
    expect(
      restored.patternEvents.every((event) => event.date == _today),
      isTrue,
      reason: 'dianggap terjadi pada sesi terakhir yang diketahui',
    );

    // Peta kelemahan pengguna lama tetap terbaca, tidak hilang.
    final insights = PatternInsights.from(
      events: restored.patternEvents,
      now: _today,
    );
    expect(insights.first.patternId, 'particle_place');
    expect(insights.first.weakness, PatternWeakness.accuracy);
  });

  test('data rusak tidak membuat app gagal dibuka', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      _key: 'bukan json',
    });

    final restored = await dataSource.read();

    expect(restored.streakDays, 0);
    expect(restored.patternEvents, isEmpty);
  });
}
