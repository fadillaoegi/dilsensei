import '../entities/learning_progress.dart';
import 'drill_session_engine.dart';

/// Aturan pembaruan progres setelah sesi tuntas.
///
/// Logikanya murni supaya bisa diuji tanpa penyimpanan maupun jam sistem.
abstract final class ProgressRules {
  /// Menghitung progres baru dari [previous] setelah sebuah sesi selesai.
  ///
  /// Streak bertambah hanya bila sesi terakhir terjadi kemarin. Sesi kedua di
  /// hari yang sama tidak menambah streak, tapi tetap menambah total sesi.
  static LearningProgress afterSession({
    required LearningProgress previous,
    required SessionSummary summary,
    required DateTime now,
  }) {
    final today = dateOnly(now);
    final last = previous.lastSessionDate;

    final streakDays = switch (last) {
      null => 1,
      _ when last == today => previous.streakDays.clamp(1, 100000),
      _ when last == today.subtract(const Duration(days: 1)) =>
        previous.streakDays + 1,
      _ => 1,
    };

    final missCounts = <String, int>{...previous.patternMissCounts};
    for (final miss in summary.weakPatterns) {
      missCounts[miss.patternId] =
          (missCounts[miss.patternId] ?? 0) + miss.missCount;
    }

    return LearningProgress(
      streakDays: streakDays,
      lastSessionDate: today,
      totalSessions: previous.totalSessions + 1,
      bestReflexScore: summary.reflexScore > previous.bestReflexScore
          ? summary.reflexScore
          : previous.bestReflexScore,
      patternMissCounts: Map<String, int>.unmodifiable(missCounts),
    );
  }

  /// Streak dianggap terputus bila sesi terakhir bukan hari ini atau kemarin.
  static bool isStreakBroken({
    required LearningProgress progress,
    required DateTime now,
  }) {
    final last = progress.lastSessionDate;
    if (last == null) return false;

    final today = dateOnly(now);
    return last != today && last != today.subtract(const Duration(days: 1));
  }

  /// Streak yang layak ditampilkan; nol bila sudah terputus.
  static int displayStreak({
    required LearningProgress progress,
    required DateTime now,
  }) {
    return isStreakBroken(progress: progress, now: now)
        ? 0
        : progress.streakDays;
  }

  static DateTime dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
