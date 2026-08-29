import 'package:dilsensei/features/lesson/domain/entities/learning_progress.dart';
import 'package:dilsensei/features/lesson/domain/entities/pattern_event.dart';
import 'package:dilsensei/features/lesson/domain/services/drill_session_engine.dart';
import 'package:dilsensei/features/lesson/domain/services/progress_rules.dart';
import 'package:flutter_test/flutter_test.dart';

SessionSummary _summary({
  int reflexScore = 80,
  int firstTryCorrect = 2,
  List<PatternMiss> weakPatterns = const <PatternMiss>[],
  List<PatternObservation> observations = const <PatternObservation>[],
}) {
  return SessionSummary(
    plannedCount: 2,
    firstTryCorrect: firstTryCorrect,
    totalAttempts: 2,
    medianResponseTime: const Duration(seconds: 3),
    weakPatterns: weakPatterns,
    reflexScore: reflexScore,
    patternObservations: observations,
  );
}

LearningProgress _progress({
  int streakDays = 0,
  DateTime? lastSessionDate,
  int totalSessions = 0,
  int bestReflexScore = 0,
  List<PatternEvent> patternEvents = const <PatternEvent>[],
  Set<String> completedModuleIds = const <String>{},
  int sessionsToday = 0,
  List<SessionRecord> recentSessions = const <SessionRecord>[],
}) {
  return LearningProgress(
    streakDays: streakDays,
    lastSessionDate: lastSessionDate,
    totalSessions: totalSessions,
    bestReflexScore: bestReflexScore,
    patternEvents: patternEvents,
    completedModuleIds: completedModuleIds,
    sessionsToday: sessionsToday,
    recentSessions: recentSessions,
  );
}

final _today = DateTime(2026, 9, 1, 20, 30);
final _yesterday = DateTime(2026, 8, 31);

void main() {
  group('ProgressRules.afterSession', () {
    test('sesi pertama memulai streak dan hitungan harian di angka satu', () {
      final progress = ProgressRules.afterSession(
        previous: const LearningProgress.empty(),
        summary: _summary(),
        now: _today,
      );

      expect(progress.streakDays, 1);
      expect(progress.totalSessions, 1);
      expect(progress.sessionsToday, 1);
      expect(progress.bestReflexScore, 80);
      expect(progress.lastSessionDate, DateTime(2026, 9, 1));
    });

    test('sesi kemarin membuat streak bertambah dan hitungan harian reset', () {
      final progress = ProgressRules.afterSession(
        previous: _progress(
          streakDays: 4,
          lastSessionDate: _yesterday,
          totalSessions: 4,
          sessionsToday: 3,
        ),
        summary: _summary(),
        now: _today,
      );

      expect(progress.streakDays, 5);
      expect(progress.totalSessions, 5);
      expect(progress.sessionsToday, 1, reason: 'hari baru mulai dari satu');
    });

    test('sesi kedua di hari yang sama menambah hitungan harian saja', () {
      final progress = ProgressRules.afterSession(
        previous: _progress(
          streakDays: 3,
          lastSessionDate: DateTime(2026, 9, 1),
          totalSessions: 3,
          bestReflexScore: 90,
          sessionsToday: 1,
        ),
        summary: _summary(reflexScore: 60),
        now: _today,
      );

      expect(progress.streakDays, 3);
      expect(progress.totalSessions, 4);
      expect(progress.sessionsToday, 2);
      expect(
        progress.bestReflexScore,
        90,
        reason: 'skor terbaik dipertahankan',
      );
    });

    test('bolong satu hari mengulang streak dari satu', () {
      final progress = ProgressRules.afterSession(
        previous: _progress(
          streakDays: 9,
          lastSessionDate: DateTime(2026, 8, 29),
          totalSessions: 9,
        ),
        summary: _summary(),
        now: _today,
      );

      expect(progress.streakDays, 1);
    });

    test('peristiwa pola dicatat bertanggal dan ditumpuk di depan', () {
      final progress = ProgressRules.afterSession(
        previous: _progress(
          streakDays: 1,
          lastSessionDate: _yesterday,
          totalSessions: 1,
          patternEvents: <PatternEvent>[
            PatternEvent(
              patternId: 'particle_place',
              date: _yesterday,
              wasCorrect: false,
              responseTime: const Duration(seconds: 6),
            ),
          ],
        ),
        summary: _summary(
          observations: const [
            PatternObservation(
              patternId: 'particle_place',
              wasCorrect: false,
              responseTime: Duration(seconds: 5),
            ),
            PatternObservation(
              patternId: 'past_form',
              wasCorrect: true,
              responseTime: Duration(seconds: 2),
            ),
          ],
        ),
        now: _today,
      );

      expect(progress.patternEvents.length, 3);
      expect(progress.patternEvents.first.patternId, 'particle_place');
      expect(progress.patternEvents.first.date, DateTime(2026, 9, 1));
      expect(progress.patternEvents.first.wasCorrect, isFalse);
      expect(progress.patternEvents.last.date, _yesterday);
    });

    test('modul yang diselesaikan dicatat tanpa duplikat', () {
      var progress = ProgressRules.afterSession(
        previous: const LearningProgress.empty(),
        summary: _summary(),
        now: _today,
        moduleId: 'm1',
      );
      progress = ProgressRules.afterSession(
        previous: progress,
        summary: _summary(),
        now: _today,
        moduleId: 'm1',
      );
      progress = ProgressRules.afterSession(
        previous: progress,
        summary: _summary(),
        now: _today,
        moduleId: 'm2',
      );

      expect(progress.completedModuleIds, <String>{'m1', 'm2'});
    });

    test('sesi tanpa moduleId tidak mengubah daftar modul selesai', () {
      final progress = ProgressRules.afterSession(
        previous: _progress(completedModuleIds: const <String>{'m1'}),
        summary: _summary(),
        now: _today,
      );

      expect(progress.completedModuleIds, <String>{'m1'});
    });

    test('riwayat peristiwa pola dibatasi', () {
      var progress = const LearningProgress.empty();
      final observations = <PatternObservation>[
        for (var i = 0; i < 10; i++)
          const PatternObservation(
            patternId: 'particle_place',
            wasCorrect: false,
            responseTime: Duration(seconds: 5),
          ),
      ];

      for (var i = 0; i < 50; i++) {
        progress = ProgressRules.afterSession(
          previous: progress,
          summary: _summary(observations: observations),
          now: _today,
        );
      }

      expect(progress.patternEvents.length, LearningProgress.maxPatternEvents);
    });

    test('riwayat menyimpan sesi terbaru di depan', () {
      var progress = ProgressRules.afterSession(
        previous: const LearningProgress.empty(),
        summary: _summary(reflexScore: 55, firstTryCorrect: 1),
        now: _yesterday,
      );
      progress = ProgressRules.afterSession(
        previous: progress,
        summary: _summary(reflexScore: 91),
        now: _today,
      );

      expect(progress.recentSessions.length, 2);
      expect(progress.recentSessions.first.reflexScore, 91);
      expect(progress.recentSessions.first.date, DateTime(2026, 9, 1));
      expect(progress.recentSessions.last.reflexScore, 55);
      expect(progress.recentSessions.last.accuracy, 0.5);
    });

    test('riwayat dibatasi agar penyimpanan tidak tumbuh tanpa batas', () {
      var progress = const LearningProgress.empty();

      for (var i = 0; i < LearningProgress.maxRecentSessions + 5; i++) {
        progress = ProgressRules.afterSession(
          previous: progress,
          summary: _summary(),
          now: _today,
        );
      }

      expect(
        progress.recentSessions.length,
        LearningProgress.maxRecentSessions,
      );
      expect(progress.totalSessions, LearningProgress.maxRecentSessions + 5);
    });
  });

  group('ProgressRules.displayStreak', () {
    test('streak tetap tampil bila sesi terakhir kemarin', () {
      expect(
        ProgressRules.displayStreak(
          progress: _progress(streakDays: 6, lastSessionDate: _yesterday),
          now: _today,
        ),
        6,
      );
    });

    test('streak jadi nol bila sudah terputus', () {
      final progress = _progress(
        streakDays: 6,
        lastSessionDate: DateTime(2026, 8, 25),
      );

      expect(
        ProgressRules.isStreakBroken(progress: progress, now: _today),
        isTrue,
      );
      expect(ProgressRules.displayStreak(progress: progress, now: _today), 0);
    });

    test('pengguna baru menampilkan streak nol tanpa dianggap terputus', () {
      const progress = LearningProgress.empty();

      expect(
        ProgressRules.isStreakBroken(progress: progress, now: _today),
        isFalse,
      );
      expect(ProgressRules.displayStreak(progress: progress, now: _today), 0);
    });
  });

  group('batas sesi harian', () {
    test('hitungan harian hanya berlaku untuk hari ini', () {
      expect(
        ProgressRules.sessionsCompletedToday(
          progress: _progress(
            lastSessionDate: DateTime(2026, 9, 1),
            sessionsToday: 3,
          ),
          now: _today,
        ),
        3,
      );
      expect(
        ProgressRules.sessionsCompletedToday(
          progress: _progress(lastSessionDate: _yesterday, sessionsToday: 3),
          now: _today,
        ),
        0,
        reason: 'kuota kemarin tidak ikut terhitung',
      );
    });

    test('pengguna gratis dibatasi satu sesi per hari', () {
      expect(
        ProgressRules.canStartSession(
          progress: const LearningProgress.empty(),
          now: _today,
          isPremium: false,
        ),
        isTrue,
      );

      expect(
        ProgressRules.canStartSession(
          progress: _progress(
            lastSessionDate: DateTime(2026, 9, 1),
            sessionsToday: ProgressRules.freeDailySessionLimit,
          ),
          now: _today,
          isPremium: false,
        ),
        isFalse,
      );
    });

    test('kuota gratis kembali pada hari berikutnya', () {
      expect(
        ProgressRules.canStartSession(
          progress: _progress(lastSessionDate: _yesterday, sessionsToday: 5),
          now: _today,
          isPremium: false,
        ),
        isTrue,
      );
    });

    test('premium tidak pernah dibatasi', () {
      expect(
        ProgressRules.canStartSession(
          progress: _progress(
            lastSessionDate: DateTime(2026, 9, 1),
            sessionsToday: 99,
          ),
          now: _today,
          isPremium: true,
        ),
        isTrue,
      );
    });
  });
}
