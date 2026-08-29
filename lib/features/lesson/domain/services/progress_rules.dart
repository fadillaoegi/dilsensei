import '../entities/learning_progress.dart';
import '../entities/pattern_event.dart';
import 'drill_session_engine.dart';

/// Aturan pembaruan progres setelah sesi tuntas.
///
/// Logikanya murni supaya bisa diuji tanpa penyimpanan maupun jam sistem.
abstract final class ProgressRules {
  /// Batas sesi harian untuk pengguna gratis.
  ///
  /// Premium membuka sesi tanpa batas, sesuai janji di paywall.
  static const freeDailySessionLimit = 1;

  /// Menghitung progres baru dari [previous] setelah sebuah sesi selesai.
  ///
  /// Streak bertambah hanya bila sesi terakhir terjadi kemarin. Sesi kedua di
  /// hari yang sama tidak menambah streak, tapi tetap menambah total sesi.
  static LearningProgress afterSession({
    required LearningProgress previous,
    required SessionSummary summary,
    required DateTime now,
    String? moduleId,
  }) {
    final today = dateOnly(now);
    final last = previous.lastSessionDate;
    final isSameDay = last == today;

    final streakDays = switch (last) {
      null => 1,
      _ when isSameDay => previous.streakDays.clamp(1, 100000),
      _ when last == today.subtract(const Duration(days: 1)) =>
        previous.streakDays + 1,
      _ => 1,
    };

    final events = <PatternEvent>[
      for (final observation in summary.patternObservations)
        PatternEvent(
          patternId: observation.patternId,
          date: today,
          wasCorrect: observation.wasCorrect,
          responseTime: observation.responseTime,
        ),
      ...previous.patternEvents,
    ].take(LearningProgress.maxPatternEvents).toList(growable: false);

    final records = <SessionRecord>[
      SessionRecord(
        date: today,
        reflexScore: summary.reflexScore,
        firstTryCorrect: summary.firstTryCorrect,
        plannedCount: summary.plannedCount,
      ),
      ...previous.recentSessions,
    ].take(LearningProgress.maxRecentSessions).toList(growable: false);

    return LearningProgress(
      streakDays: streakDays,
      lastSessionDate: today,
      totalSessions: previous.totalSessions + 1,
      bestReflexScore: summary.reflexScore > previous.bestReflexScore
          ? summary.reflexScore
          : previous.bestReflexScore,
      patternEvents: List<PatternEvent>.unmodifiable(events),
      sessionsToday: isSameDay ? previous.sessionsToday + 1 : 1,
      recentSessions: List<SessionRecord>.unmodifiable(records),
      completedModuleIds: Set<String>.unmodifiable(<String>{
        ...previous.completedModuleIds,
        ?moduleId,
      }),
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

  /// Jumlah sesi yang sudah diselesaikan hari ini.
  static int sessionsCompletedToday({
    required LearningProgress progress,
    required DateTime now,
  }) {
    return progress.lastSessionDate == dateOnly(now)
        ? progress.sessionsToday
        : 0;
  }

  /// Apakah pengguna masih boleh memulai sesi baru hari ini.
  static bool canStartSession({
    required LearningProgress progress,
    required DateTime now,
    required bool isPremium,
  }) {
    if (isPremium) return true;

    return sessionsCompletedToday(progress: progress, now: now) <
        freeDailySessionLimit;
  }

  static DateTime dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
