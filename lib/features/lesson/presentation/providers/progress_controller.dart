import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/progress_local_data_source.dart';
import '../../domain/entities/learning_progress.dart';
import '../../domain/services/drill_session_engine.dart';
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

  /// Dipanggil sekali saat sesi tuntas.
  Future<void> recordSession(SessionSummary summary) async {
    final updated = ProgressRules.afterSession(
      previous: state,
      summary: summary,
      now: now(),
    );

    state = updated;
    await dataSource.write(updated);
  }

  /// Streak yang layak ditampilkan hari ini.
  int get displayStreak =>
      ProgressRules.displayStreak(progress: state, now: now());
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
