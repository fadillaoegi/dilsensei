import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/onboarding_local_data_source.dart';
import '../../domain/onboarding_preferences.dart';

final onboardingDataSourceProvider = Provider<OnboardingLocalDataSource>((ref) {
  return const OnboardingLocalDataSource();
});

/// Preferensi tersimpan. Selama masih memuat, UI menampilkan splash minimalis
/// alih-alih menebak dan berkedip antara onboarding dan Home.
final onboardingPreferencesProvider = FutureProvider<OnboardingPreferences>((
  ref,
) {
  return ref.watch(onboardingDataSourceProvider).read();
});

/// State wizard onboarding selama diisi pengguna.
@immutable
class OnboardingDraft {
  const OnboardingDraft({
    this.step = 0,
    this.name = '',
    this.goal,
    this.dailyTarget,
    this.isSaving = false,
  });

  static const totalSteps = 3;

  final int step;
  final String name;
  final LearningGoal? goal;
  final DailyTarget? dailyTarget;
  final bool isSaving;

  bool get isLastStep => step == totalSteps - 1;

  /// Apakah langkah saat ini sudah cukup untuk lanjut.
  bool get canContinue => switch (step) {
    0 => name.trim().length >= 2,
    1 => goal != null,
    2 => dailyTarget != null,
    _ => false,
  };

  OnboardingDraft copyWith({
    int? step,
    String? name,
    LearningGoal? goal,
    DailyTarget? dailyTarget,
    bool? isSaving,
  }) {
    return OnboardingDraft(
      step: step ?? this.step,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class OnboardingController extends StateNotifier<OnboardingDraft> {
  OnboardingController({required this.dataSource, required this.onCompleted})
    : super(const OnboardingDraft());

  final OnboardingLocalDataSource dataSource;

  /// Dipanggil setelah preferensi tersimpan, untuk menyegarkan provider.
  final void Function() onCompleted;

  void setName(String value) => state = state.copyWith(name: value);

  void selectGoal(LearningGoal goal) => state = state.copyWith(goal: goal);

  void selectTarget(DailyTarget target) =>
      state = state.copyWith(dailyTarget: target);

  void back() {
    if (state.step == 0) return;
    state = state.copyWith(step: state.step - 1);
  }

  /// Maju satu langkah, atau menyimpan bila sudah di langkah terakhir.
  Future<void> next() async {
    if (!state.canContinue || state.isSaving) return;

    if (!state.isLastStep) {
      state = state.copyWith(step: state.step + 1);
      return;
    }

    state = state.copyWith(isSaving: true);
    await dataSource.write(
      OnboardingPreferences(
        name: state.name.trim(),
        goal: state.goal ?? LearningGoal.culture,
        dailyTarget: state.dailyTarget ?? DailyTarget.steady,
        isCompleted: true,
      ),
    );

    if (!mounted) return;
    state = state.copyWith(isSaving: false);
    onCompleted();
  }
}

final onboardingControllerProvider =
    StateNotifierProvider.autoDispose<OnboardingController, OnboardingDraft>((
      ref,
    ) {
      return OnboardingController(
        dataSource: ref.watch(onboardingDataSourceProvider),
        onCompleted: () => ref.invalidate(onboardingPreferencesProvider),
      );
    });

/// Nama panggilan untuk sapaan; kosong berarti sapaan generik.
final userNameProvider = Provider<String>((ref) {
  final name = ref.watch(onboardingPreferencesProvider).valueOrNull?.name ?? '';

  return name.isEmpty ? 'Sensei' : name;
});
