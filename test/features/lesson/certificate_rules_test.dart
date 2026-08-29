import 'package:dilsensei/features/lesson/domain/entities/learning_progress.dart';
import 'package:dilsensei/features/lesson/domain/entities/pattern_event.dart';
import 'package:dilsensei/features/lesson/domain/services/certificate_rules.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 9, 10, 12);
const _allModules = <String>['m1', 'm2', 'm3'];

PatternEvent _event(
  String patternId, {
  required bool correct,
  int seconds = 2,
  int daysAgo = 0,
}) {
  return PatternEvent(
    patternId: patternId,
    date: DateTime(2026, 9, 10).subtract(Duration(days: daysAgo)),
    wasCorrect: correct,
    responseTime: Duration(seconds: seconds),
  );
}

SessionRecord _session({
  required int day,
  int firstTryCorrect = 8,
  int plannedCount = 8,
}) {
  return SessionRecord(
    date: DateTime(2026, 9, day),
    reflexScore: 80,
    firstTryCorrect: firstTryCorrect,
    plannedCount: plannedCount,
  );
}

LearningProgress _progress({
  Set<String> completed = const <String>{'m1', 'm2', 'm3'},
  List<SessionRecord> sessions = const <SessionRecord>[],
  List<PatternEvent> events = const <PatternEvent>[],
  int totalSessions = 3,
}) {
  return LearningProgress(
    streakDays: 3,
    lastSessionDate: DateTime(2026, 9, 10),
    totalSessions: totalSessions,
    bestReflexScore: 90,
    patternEvents: events,
    sessionsToday: 1,
    recentSessions: sessions,
    completedModuleIds: completed,
  );
}

void main() {
  group('kelayakan', () {
    test('belum layak sebelum semua modul diselesaikan', () {
      expect(
        CertificateRules.isEligible(
          progress: _progress(completed: const <String>{'m1', 'm2'}),
          allModuleIds: _allModules,
        ),
        isFalse,
      );
    });

    test('layak setelah setiap modul pernah tuntas', () {
      expect(
        CertificateRules.isEligible(
          progress: _progress(),
          allModuleIds: _allModules,
        ),
        isTrue,
      );
    });

    test('daftar modul kosong tidak pernah dianggap layak', () {
      expect(
        CertificateRules.isEligible(
          progress: _progress(),
          allModuleIds: const <String>[],
        ),
        isFalse,
      );
    });

    test('modul tambahan yang belum ada isinya membuat tidak layak lagi', () {
      expect(
        CertificateRules.isEligible(
          progress: _progress(),
          allModuleIds: const <String>['m1', 'm2', 'm3', 'm4'],
        ),
        isFalse,
      );
    });
  });

  group('komponen skor', () {
    test('sempurna pada empat komponen menghasilkan 100', () {
      final record = CertificateRules.evaluate(
        progress: _progress(
          sessions: <SessionRecord>[
            for (var day = 4; day <= 10; day++) _session(day: day),
          ],
          events: <PatternEvent>[
            for (var i = 0; i < 10; i++)
              _event('particle_place', correct: true),
            for (var i = 0; i < 10; i++) _event('past_form', correct: true),
          ],
        ),
        allModuleIds: _allModules,
        now: _now,
      );

      expect(record.accuracy, 1);
      expect(record.speed, 1);
      expect(record.mastery, 1);
      expect(record.consistency, 1);
      expect(record.score, 100);
      expect(record.tier, RecordTier.reflex);
    });

    test('akurasi separuh menurunkan skor sesuai bobotnya', () {
      final record = CertificateRules.evaluate(
        progress: _progress(
          sessions: <SessionRecord>[
            for (var day = 4; day <= 10; day++)
              _session(day: day, firstTryCorrect: 4),
          ],
          events: <PatternEvent>[
            for (var i = 0; i < 10; i++)
              _event('particle_place', correct: true),
          ],
        ),
        allModuleIds: _allModules,
        now: _now,
      );

      // 100 - 40% * 50% = 80
      expect(record.accuracy, 0.5);
      expect(record.score, 80);
      expect(record.tier, RecordTier.sharp);
    });

    test('benar tapi lambat menurunkan komponen kecepatan', () {
      final record = CertificateRules.evaluate(
        progress: _progress(
          sessions: <SessionRecord>[
            for (var day = 4; day <= 10; day++) _session(day: day),
          ],
          events: <PatternEvent>[
            for (var i = 0; i < 10; i++)
              _event('particle_place', correct: true, seconds: 8),
          ],
        ),
        allModuleIds: _allModules,
        now: _now,
      );

      expect(record.speed, closeTo(0.5, 0.01));
      expect(record.medianResponseTime, const Duration(seconds: 8));
      expect(record.score, lessThan(90));
    });

    test('tanpa data sama sekali menghasilkan nol', () {
      final record = CertificateRules.evaluate(
        progress: _progress(),
        allModuleIds: _allModules,
        now: _now,
      );

      expect(record.score, 0);
      expect(record.tier, RecordTier.completed);
      expect(record.medianResponseTime, Duration.zero);
    });
  });

  group('ketahanan terhadap pengulangan modul mudah', () {
    test('mengulang satu pola mudah tidak membuat skor penuh', () {
      // Dua puluh sesi sempurna, tapi hanya satu pola yang pernah dilatih dan
      // ada satu pola lain yang masih sering salah.
      final record = CertificateRules.evaluate(
        progress: _progress(
          totalSessions: 20,
          sessions: <SessionRecord>[
            for (var day = 4; day <= 10; day++) _session(day: day),
          ],
          events: <PatternEvent>[
            for (var i = 0; i < 30; i++)
              _event('particle_place', correct: true),
            for (var i = 0; i < 5; i++) _event('counter_word', correct: false),
          ],
        ),
        allModuleIds: _allModules,
        now: _now,
      );

      expect(record.accuracy, 1);
      expect(
        record.mastery,
        0.5,
        reason: 'satu dari dua pola masih belum jadi refleks',
      );
      expect(
        record.score,
        lessThan(90),
        reason: 'volume sesi tidak boleh menutupi pola yang lemah',
      );
    });

    test('memperbaiki pola lemah menaikkan skor', () {
      List<PatternEvent> events({required bool fixed}) => <PatternEvent>[
        for (var i = 0; i < 30; i++) _event('particle_place', correct: true),
        if (fixed)
          for (var i = 0; i < 10; i++) _event('counter_word', correct: true)
        else
          for (var i = 0; i < 5; i++) _event('counter_word', correct: false),
      ];

      int scoreWith({required bool fixed}) => CertificateRules.evaluate(
        progress: _progress(
          sessions: <SessionRecord>[
            for (var day = 4; day <= 10; day++) _session(day: day),
          ],
          events: events(fixed: fixed),
        ),
        allModuleIds: _allModules,
        now: _now,
      ).score;

      expect(scoreWith(fixed: true), greaterThan(scoreWith(fixed: false)));
    });
  });

  group('tingkatan', () {
    test('batas tiap tingkatan', () {
      expect(CertificateRules.tierFor(100), RecordTier.reflex);
      expect(CertificateRules.tierFor(90), RecordTier.reflex);
      expect(CertificateRules.tierFor(89), RecordTier.sharp);
      expect(CertificateRules.tierFor(80), RecordTier.sharp);
      expect(CertificateRules.tierFor(79), RecordTier.steady);
      expect(CertificateRules.tierFor(70), RecordTier.steady);
      expect(CertificateRules.tierFor(69), RecordTier.completed);
      expect(CertificateRules.tierFor(0), RecordTier.completed);
    });
  });
}
