import '../../../l10n/app_localizations.dart';

/// Tujuan belajar yang dipilih saat onboarding.
///
/// Dipakai untuk menentukan urutan modul dan nada pesan pengingat.
enum LearningGoal {
  work,
  travel,
  culture,
  exam;

  String labelFor(AppL10n l10n) => switch (this) {
    LearningGoal.work => l10n.goalWorkLabel,
    LearningGoal.travel => l10n.goalTravelLabel,
    LearningGoal.culture => l10n.goalCultureLabel,
    LearningGoal.exam => l10n.goalExamLabel,
  };

  String descriptionFor(AppL10n l10n) => switch (this) {
    LearningGoal.work => l10n.goalWorkDescription,
    LearningGoal.travel => l10n.goalTravelDescription,
    LearningGoal.culture => l10n.goalCultureDescription,
    LearningGoal.exam => l10n.goalExamDescription,
  };
}

/// Target latihan harian dalam menit.
enum DailyTarget {
  light(5),
  steady(10),
  intense(15);

  const DailyTarget(this.minutes);

  final int minutes;

  String labelFor(AppL10n l10n) => switch (this) {
    DailyTarget.light => l10n.targetLightLabel,
    DailyTarget.steady => l10n.targetSteadyLabel,
    DailyTarget.intense => l10n.targetIntenseLabel,
  };

  String descriptionFor(AppL10n l10n) => switch (this) {
    DailyTarget.light => l10n.targetLightDescription,
    DailyTarget.steady => l10n.targetSteadyDescription,
    DailyTarget.intense => l10n.targetIntenseDescription,
  };
}

/// Preferensi hasil onboarding, disimpan lokal.
class OnboardingPreferences {
  const OnboardingPreferences({
    required this.name,
    required this.goal,
    required this.dailyTarget,
    required this.isCompleted,
  });

  const OnboardingPreferences.empty()
    : name = '',
      goal = LearningGoal.culture,
      dailyTarget = DailyTarget.steady,
      isCompleted = false;

  /// Nama panggilan untuk sapaan di HomeScreen.
  final String name;
  final LearningGoal goal;
  final DailyTarget dailyTarget;
  final bool isCompleted;

  OnboardingPreferences copyWith({
    String? name,
    LearningGoal? goal,
    DailyTarget? dailyTarget,
    bool? isCompleted,
  }) {
    return OnboardingPreferences(
      name: name ?? this.name,
      goal: goal ?? this.goal,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
