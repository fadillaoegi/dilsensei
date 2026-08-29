import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/language_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/datasources/local_reminder_scheduler.dart';
import '../../data/datasources/reminder_local_data_source.dart';
import '../../domain/entities/grammar_pattern.dart';
import '../../domain/services/reminder_rules.dart';
import '../../domain/services/reminder_scheduler.dart';
import 'progress_controller.dart';

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return LocalReminderScheduler();
});

final reminderDataSourceProvider = Provider<ReminderLocalDataSource>((ref) {
  return const ReminderLocalDataSource();
});

/// Mengelola preferensi pengingat dan menjadwalkan notifikasinya.
class ReminderController extends StateNotifier<ReminderPreferences> {
  ReminderController({
    required this.dataSource,
    required this.scheduler,
    required this.buildContent,
  }) : super(const ReminderPreferences.defaults()) {
    _load();
  }

  final ReminderLocalDataSource dataSource;
  final ReminderScheduler scheduler;

  /// Menyusun isi notifikasi untuk jam tertentu, memakai bahasa aktif.
  final ReminderContent? Function({required int hour, required int minute})
  buildContent;

  Future<void> _load() async {
    final stored = await dataSource.read();
    if (!mounted) return;

    state = stored;
    if (stored.isEnabled) await _reschedule();
  }

  /// Menyalakan atau mematikan pengingat.
  ///
  /// Mengembalikan false bila izin notifikasi ditolak, supaya UI bisa memberi
  /// tahu pengguna alih-alih diam-diam gagal.
  Future<bool> setEnabled(bool isEnabled) async {
    if (!isEnabled) {
      state = state.copyWith(isEnabled: false);
      await dataSource.write(state);
      await scheduler.cancel();

      return true;
    }

    final granted = await scheduler.requestPermission();
    if (!granted) return false;

    state = state.copyWith(isEnabled: true);
    await dataSource.write(state);
    await _reschedule();

    return true;
  }

  Future<void> setTime({required int hour, required int minute}) async {
    state = state.copyWith(hour: hour, minute: minute);
    await dataSource.write(state);

    if (state.isEnabled) await _reschedule();
  }

  /// Menyegarkan isi dan jadwal pengingat sesuai kondisi terbaru.
  Future<void> refresh() async {
    if (!state.isEnabled) return;

    await _reschedule();
  }

  Future<void> _reschedule() async {
    final content = buildContent(hour: state.hour, minute: state.minute);
    if (content == null) {
      await scheduler.cancel();
      return;
    }

    await scheduler.schedule(content);
  }
}

/// Menyusun isi pengingat dari kondisi progres dan bahasa aktif.
///
/// Dipisah dari controller supaya bisa diuji langsung tanpa penjadwal.
ReminderContent? buildReminderContent({
  required AppL10n l10n,
  required ReminderPlan plan,
}) {
  if (!plan.shouldSchedule) return null;

  final patternLabel = plan.patternId == null
      ? ''
      : GrammarPatterns.labelOf(l10n, plan.patternId!);

  return switch (plan.tone) {
    ReminderTone.weakAccuracy => ReminderContent(
      title: l10n.reminderTitleWeakAccuracy(patternLabel),
      body: l10n.reminderBodyWeakAccuracy,
      scheduledFor: plan.scheduledFor,
    ),
    ReminderTone.weakSpeed => ReminderContent(
      title: l10n.reminderTitleWeakSpeed(patternLabel),
      body: l10n.reminderBodyWeakSpeed,
      scheduledFor: plan.scheduledFor,
    ),
    ReminderTone.streakAtRisk => ReminderContent(
      title: l10n.reminderTitleStreak,
      body: l10n.reminderBodyStreak,
      scheduledFor: plan.scheduledFor,
    ),
    ReminderTone.firstSession => ReminderContent(
      title: l10n.reminderTitleFirst,
      body: l10n.reminderBodyFirst,
      scheduledFor: plan.scheduledFor,
    ),
    ReminderTone.none => null,
  };
}

/// Rencana pengingat saat ini, dihitung dari riwayat pola dan latihan hari ini.
final reminderPlanProvider = Provider.family<ReminderPlan, ReminderPreferences>(
  (ref, preferences) {
    final progress = ref.watch(progressControllerProvider);
    final now = ref.watch(nowProvider)();

    return ReminderRules.plan(
      events: progress.patternEvents,
      practisedToday: ref.watch(sessionsTodayProvider) > 0,
      streakDays: ref.watch(displayStreakProvider),
      now: now,
      hour: preferences.hour,
      minute: preferences.minute,
    );
  },
);

final reminderControllerProvider =
    StateNotifierProvider<ReminderController, ReminderPreferences>((ref) {
      return ReminderController(
        dataSource: ref.watch(reminderDataSourceProvider),
        scheduler: ref.watch(reminderSchedulerProvider),
        buildContent: ({required int hour, required int minute}) {
          // Teks diambil lewat lookupAppL10n, bukan BuildContext, supaya isi
          // notifikasi bisa disusun di luar widget tree.
          final l10n = lookupAppL10n(ref.read(localeProvider));
          final preferences = ReminderPreferences(
            isEnabled: true,
            hour: hour,
            minute: minute,
          );

          return buildReminderContent(
            l10n: l10n,
            plan: ref.read(reminderPlanProvider(preferences)),
          );
        },
      );
    });
