import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/monetization/dev_premium_override.dart';
import '../../../../core/monetization/monetization_providers.dart';
import '../../../onboarding/presentation/providers/onboarding_controller.dart';
import '../../data/datasources/progress_local_data_source.dart';
import '../../domain/entities/grammar_pattern.dart';
import '../../domain/entities/learning_progress.dart';
import '../../domain/entities/pattern_event.dart';
import '../../domain/services/day_parts.dart';
import '../../domain/services/drill_session_engine.dart';
import '../../domain/services/pattern_insights.dart';
import '../../domain/services/progress_rules.dart';

final progressDataSourceProvider = Provider<ProgressLocalDataSource>((ref) {
  return const ProgressLocalDataSource();
});

/// Jam yang dapat diganti di test agar perilaku streak deterministik.
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class ProgressController extends StateNotifier<LearningProgress> {
  ProgressController({required this.dataSource, required this.now})
    : super(const LearningProgress.empty()) {
    _load();
  }

  final ProgressLocalDataSource dataSource;
  final DateTime Function() now;

  Future<void> _load() async {
    final stored = await dataSource.read();
    if (!mounted) return;

    state = stored;
  }

  /// Mengisi progres sintetis agar Training Record bisa diperiksa saat
  /// pengembangan.
  ///
  /// Hanya berjalan bila [DevTools.isEnabled], yaitu build debug atau profile,
  /// sehingga tidak mungkin dipakai untuk memalsukan sertifikat di produksi.
  Future<void> devCompleteAllModules(List<String> moduleIds) async {
    if (!DevTools.isEnabled) return;

    final today = ProgressRules.dateOnly(now());
    final events = <PatternEvent>[
      for (final patternId in GrammarPatterns.all)
        for (var i = 0; i < 6; i++)
          PatternEvent(
            patternId: patternId,
            date: today.subtract(Duration(days: i % 5)),
            wasCorrect: i != 0,
            responseTime: Duration(milliseconds: 2600 + (i * 220)),
          ),
    ];

    final sessions = <SessionRecord>[
      for (var day = 0; day < moduleIds.length; day++)
        SessionRecord(
          date: today.subtract(Duration(days: day)),
          reflexScore: 82,
          firstTryCorrect: 7,
          plannedCount: 8,
        ),
    ];

    final updated = LearningProgress(
      streakDays: moduleIds.length,
      lastSessionDate: today,
      totalSessions: moduleIds.length,
      bestReflexScore: 88,
      patternEvents: List<PatternEvent>.unmodifiable(events),
      sessionsToday: 1,
      recentSessions: List<SessionRecord>.unmodifiable(sessions),
      completedModuleIds: Set<String>.unmodifiable(moduleIds),
    );

    state = updated;
    await dataSource.write(updated);
  }

  /// Dipanggil sekali saat sesi tuntas.
  Future<void> recordSession(SessionSummary summary, {String? moduleId}) async {
    final updated = ProgressRules.afterSession(
      previous: state,
      summary: summary,
      now: now(),
      moduleId: moduleId,
    );

    state = updated;
    await dataSource.write(updated);
  }
}

final progressControllerProvider =
    StateNotifierProvider<ProgressController, LearningProgress>((ref) {
      return ProgressController(
        dataSource: ref.watch(progressDataSourceProvider),
        now: ref.watch(nowProvider),
      );
    });

/// Streak untuk header HomeScreen, sudah memperhitungkan streak yang terputus.
final displayStreakProvider = Provider<int>((ref) {
  final progress = ref.watch(progressControllerProvider);
  final now = ref.watch(nowProvider)();

  return ProgressRules.displayStreak(progress: progress, now: now);
});

/// Jumlah sesi yang sudah diselesaikan hari ini.
final sessionsTodayProvider = Provider<int>((ref) {
  final progress = ref.watch(progressControllerProvider);
  final now = ref.watch(nowProvider)();

  return ProgressRules.sessionsCompletedToday(progress: progress, now: now);
});

/// Apakah pengguna masih boleh memulai sesi baru hari ini.
///
/// Pengguna gratis dibatasi [ProgressRules.freeDailySessionLimit] sesi per hari;
/// premium tanpa batas, sesuai janji di paywall.
final canStartSessionProvider = Provider<bool>((ref) {
  return ProgressRules.canStartSession(
    progress: ref.watch(progressControllerProvider),
    now: ref.watch(nowProvider)(),
    isPremium: ref.watch(isPremiumProvider),
  );
});

/// Bagian hari saat ini, penentu sapaan di Home.
final dayPartProvider = Provider<DayPart>((ref) {
  return DayParts.from(ref.watch(nowProvider)());
});

/// Analisis pola: kesalahan lama memudar dan jawaban lambat ikut dihitung.
final patternInsightsProvider = Provider<List<PatternInsight>>((ref) {
  return PatternInsights.from(
    events: ref.watch(progressControllerProvider).patternEvents,
    now: ref.watch(nowProvider)(),
  );
});

/// Pola yang masih perlu dilatih, terurut dari paling berisiko.
final weakPatternIdsProvider = Provider<List<String>>((ref) {
  return ref
      .watch(patternInsightsProvider)
      .where((insight) => insight.weakness != PatternWeakness.none)
      .map((insight) => insight.patternId)
      .toList(growable: false);
});

/// Panjang sesi mengikuti target harian yang dipilih saat onboarding.
///
/// Perkiraannya sekitar satu butir per menit, dibulatkan ke jumlah yang enak
/// dikerjakan tanpa terasa panjang.
final sessionItemCountProvider = Provider<int>((ref) {
  final target = ref
      .watch(onboardingPreferencesProvider)
      .valueOrNull
      ?.dailyTarget;

  return switch (target?.minutes) {
    5 => 6,
    15 => 12,
    _ => 8,
  };
});
