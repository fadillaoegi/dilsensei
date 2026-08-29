import 'pattern_event.dart';

/// Satu catatan sesi yang sudah tuntas, untuk halaman riwayat.
class SessionRecord {
  const SessionRecord({
    required this.date,
    required this.reflexScore,
    required this.firstTryCorrect,
    required this.plannedCount,
  });

  final DateTime date;
  final int reflexScore;
  final int firstTryCorrect;
  final int plannedCount;

  double get accuracy => plannedCount == 0 ? 0 : firstTryCorrect / plannedCount;
}

/// Progres belajar yang disimpan lokal di perangkat.
class LearningProgress {
  const LearningProgress({
    required this.streakDays,
    required this.lastSessionDate,
    required this.totalSessions,
    required this.bestReflexScore,
    required this.patternEvents,
    required this.sessionsToday,
    required this.recentSessions,
    required this.completedModuleIds,
  });

  const LearningProgress.empty()
    : streakDays = 0,
      lastSessionDate = null,
      totalSessions = 0,
      bestReflexScore = 0,
      patternEvents = const <PatternEvent>[],
      sessionsToday = 0,
      completedModuleIds = const <String>{},
      recentSessions = const <SessionRecord>[];

  /// Jumlah maksimal catatan sesi yang disimpan agar penyimpanan tidak tumbuh
  /// tanpa batas.
  static const maxRecentSessions = 30;

  /// Batas jumlah peristiwa pola yang disimpan agar penyimpanan tetap kecil.
  static const maxPatternEvents = 400;

  final int streakDays;

  /// Tanggal sesi terakhir, tanpa komponen waktu.
  final DateTime? lastSessionDate;
  final int totalSessions;
  final int bestReflexScore;

  /// Riwayat pengamatan pola, terbaru di depan.
  ///
  /// Disimpan sebagai peristiwa bertanggal agar kesalahan lama bisa memudar dan
  /// waktu respons ikut diperhitungkan saat menyusun peta kelemahan.
  final List<PatternEvent> patternEvents;

  /// Jumlah sesi yang diselesaikan pada [lastSessionDate].
  final int sessionsToday;

  /// Riwayat sesi terbaru, terurut dari yang paling baru.
  final List<SessionRecord> recentSessions;

  /// Modul yang pernah diselesaikan minimal satu sesi.
  ///
  /// Dipakai sebagai syarat kelayakan Training Record.
  final Set<String> completedModuleIds;

  LearningProgress copyWith({
    int? streakDays,
    DateTime? lastSessionDate,
    int? totalSessions,
    int? bestReflexScore,
    List<PatternEvent>? patternEvents,
    int? sessionsToday,
    List<SessionRecord>? recentSessions,
    Set<String>? completedModuleIds,
  }) {
    return LearningProgress(
      streakDays: streakDays ?? this.streakDays,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      totalSessions: totalSessions ?? this.totalSessions,
      bestReflexScore: bestReflexScore ?? this.bestReflexScore,
      patternEvents: patternEvents ?? this.patternEvents,
      sessionsToday: sessionsToday ?? this.sessionsToday,
      recentSessions: recentSessions ?? this.recentSessions,
      completedModuleIds: completedModuleIds ?? this.completedModuleIds,
    );
  }
}
