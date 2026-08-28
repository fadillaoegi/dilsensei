/// Tujuan belajar yang dipilih saat onboarding.
///
/// Dipakai untuk menentukan urutan modul dan nada pesan pengingat.
enum LearningGoal {
  work('Untuk kerja', 'Frasa kantor, laporan, dan komunikasi tim'),
  travel('Untuk jalan-jalan', 'Bertanya arah, memesan, dan berbelanja'),
  culture('Untuk anime & budaya', 'Percakapan sehari-hari yang terasa alami'),
  exam('Untuk ujian', 'Pola tata bahasa yang sering keluar di JLPT');

  const LearningGoal(this.label, this.description);

  final String label;
  final String description;
}

/// Target latihan harian dalam menit.
enum DailyTarget {
  light(5, 'Ringan', 'Cukup untuk menjaga streak'),
  steady(10, 'Mantap', 'Paling banyak dipilih'),
  intense(15, 'Serius', 'Untuk yang sedang dikejar tenggat');

  const DailyTarget(this.minutes, this.label, this.description);

  final int minutes;
  final String label;
  final String description;
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
