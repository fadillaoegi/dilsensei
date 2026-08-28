/// Progres belajar yang disimpan lokal di perangkat.
class LearningProgress {
  const LearningProgress({
    required this.streakDays,
    required this.lastSessionDate,
    required this.totalSessions,
    required this.bestReflexScore,
    required this.patternMissCounts,
  });

  const LearningProgress.empty()
    : streakDays = 0,
      lastSessionDate = null,
      totalSessions = 0,
      bestReflexScore = 0,
      patternMissCounts = const <String, int>{};

  final int streakDays;

  /// Tanggal sesi terakhir, tanpa komponen waktu.
  final DateTime? lastSessionDate;
  final int totalSessions;
  final int bestReflexScore;

  /// Akumulasi kesalahan per pola sepanjang waktu, bukan hanya satu sesi.
  final Map<String, int> patternMissCounts;

  /// Pola terlemah sepanjang waktu, terurut dari paling sering salah.
  List<String> get weakestPatternIds {
    final entries = patternMissCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.map((entry) => entry.key).toList(growable: false);
  }

  LearningProgress copyWith({
    int? streakDays,
    DateTime? lastSessionDate,
    int? totalSessions,
    int? bestReflexScore,
    Map<String, int>? patternMissCounts,
  }) {
    return LearningProgress(
      streakDays: streakDays ?? this.streakDays,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      totalSessions: totalSessions ?? this.totalSessions,
      bestReflexScore: bestReflexScore ?? this.bestReflexScore,
      patternMissCounts: patternMissCounts ?? this.patternMissCounts,
    );
  }
}
