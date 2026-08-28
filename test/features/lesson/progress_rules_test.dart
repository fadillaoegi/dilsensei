import 'package:dilsensei/features/lesson/domain/entities/learning_progress.dart';
import 'package:dilsensei/features/lesson/domain/services/drill_session_engine.dart';
import 'package:dilsensei/features/lesson/domain/services/progress_rules.dart';
import 'package:flutter_test/flutter_test.dart';

SessionSummary _summary({
  int reflexScore = 80,
  List<PatternMiss> weakPatterns = const <PatternMiss>[],
}) {
  return SessionSummary(
    plannedCount: 2,
    firstTryCorrect: 2,
    totalAttempts: 2,
    medianResponseTime: const Duration(seconds: 3),
    weakPatterns: weakPatterns,
    reflexScore: reflexScore,
  );
}

final _today = DateTime(2026, 9, 1, 20, 30);

void main() {
  group('ProgressRules.afterSession', () {
    test('sesi pertama memulai streak di angka satu', () {
      final progress = ProgressRules.afterSession(
        previous: const LearningProgress.empty(),
        summary: _summary(),
        now: _today,
      );

      expect(progress.streakDays, 1);
      expect(progress.totalSessions, 1);
      expect(progress.bestReflexScore, 80);
      expect(progress.lastSessionDate, DateTime(2026, 9, 1));
    });

    test('sesi kemarin membuat streak bertambah', () {
      final previous = LearningProgress(
        streakDays: 4,
        lastSessionDate: DateTime(2026, 8, 31),
        totalSessions: 4,
        bestReflexScore: 70,
        patternMissCounts: const <String, int>{},
      );

      final progress = ProgressRules.afterSession(
        previous: previous,
        summary: _summary(),
        now: _today,
      );

      expect(progress.streakDays, 5);
      expect(progress.totalSessions, 5);
    });

    test('sesi kedua di hari yang sama tidak menambah streak', () {
      final previous = LearningProgress(
        streakDays: 3,
        lastSessionDate: DateTime(2026, 9, 1),
        totalSessions: 3,
        bestReflexScore: 90,
        patternMissCounts: const <String, int>{},
      );

      final progress = ProgressRules.afterSession(
        previous: previous,
        summary: _summary(reflexScore: 60),
        now: _today,
      );

      expect(progress.streakDays, 3);
      expect(progress.totalSessions, 4);
      expect(
        progress.bestReflexScore,
        90,
        reason: 'skor terbaik dipertahankan',
      );
    });

    test('bolong satu hari mengulang streak dari satu', () {
      final previous = LearningProgress(
        streakDays: 9,
        lastSessionDate: DateTime(2026, 8, 29),
        totalSessions: 9,
        bestReflexScore: 88,
        patternMissCounts: const <String, int>{},
      );

      final progress = ProgressRules.afterSession(
        previous: previous,
        summary: _summary(),
        now: _today,
      );

      expect(progress.streakDays, 1);
    });

    test('kesalahan pola diakumulasi sepanjang waktu', () {
      final previous = LearningProgress(
        streakDays: 1,
        lastSessionDate: DateTime(2026, 8, 31),
        totalSessions: 1,
        bestReflexScore: 50,
        patternMissCounts: const <String, int>{'particle_place': 2},
      );

      final progress = ProgressRules.afterSession(
        previous: previous,
        summary: _summary(
          weakPatterns: const [
            PatternMiss(patternId: 'particle_place', missCount: 3),
            PatternMiss(patternId: 'past_form', missCount: 1),
          ],
        ),
        now: _today,
      );

      expect(progress.patternMissCounts['particle_place'], 5);
      expect(progress.patternMissCounts['past_form'], 1);
      expect(progress.weakestPatternIds.first, 'particle_place');
    });
  });

  group('ProgressRules.displayStreak', () {
    test('streak tetap tampil bila sesi terakhir kemarin', () {
      final progress = LearningProgress(
        streakDays: 6,
        lastSessionDate: DateTime(2026, 8, 31),
        totalSessions: 6,
        bestReflexScore: 80,
        patternMissCounts: const <String, int>{},
      );

      expect(ProgressRules.displayStreak(progress: progress, now: _today), 6);
    });

    test('streak jadi nol bila sudah terputus', () {
      final progress = LearningProgress(
        streakDays: 6,
        lastSessionDate: DateTime(2026, 8, 25),
        totalSessions: 6,
        bestReflexScore: 80,
        patternMissCounts: const <String, int>{},
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
}
