import '../entities/learning_progress.dart';
import '../entities/pattern_event.dart';
import 'drill_session_engine.dart';
import 'pattern_insights.dart';

/// Tingkatan hasil pada Training Record.
enum RecordTier {
  /// 90 ke atas: jawaban benar dan cepat, pola sudah jadi refleks.
  reflex,

  /// 80–89: kuat, sebagian pola masih perlu dipertajam.
  sharp,

  /// 70–79: mantap, tapi kecepatan atau cakupan pola belum merata.
  steady,

  /// Di bawah 70: seluruh modul tuntas, kualitasnya masih bertumbuh.
  completed,
}

/// Rincian skor Training Record.
class TrainingRecord {
  const TrainingRecord({
    required this.score,
    required this.tier,
    required this.accuracy,
    required this.speed,
    required this.mastery,
    required this.consistency,
    required this.completedModules,
    required this.totalModules,
    required this.totalSessions,
    required this.practiceDays,
    required this.medianResponseTime,
    required this.issuedOn,
  });

  /// Skor akhir 0–100.
  final int score;
  final RecordTier tier;

  /// Empat komponen dalam rentang 0–1, ditampilkan sebagai rincian.
  final double accuracy;
  final double speed;
  final double mastery;
  final double consistency;

  final int completedModules;
  final int totalModules;
  final int totalSessions;
  final int practiceDays;
  final Duration medianResponseTime;
  final DateTime issuedOn;
}

/// Aturan kelayakan dan penilaian Training Record.
///
/// Skornya sengaja tidak bisa diakali dengan mengulang modul termudah: komponen
/// penguasaan pola hanya naik bila pola yang belum dikuasai ikut membaik, dan
/// komponen kecepatan tidak peduli berapa kali sesi diulang.
abstract final class CertificateRules {
  /// Bobot tiap komponen. Totalnya 1.
  static const accuracyWeight = 0.40;
  static const speedWeight = 0.30;
  static const masteryWeight = 0.25;
  static const consistencyWeight = 0.05;

  /// Jumlah hari berlatih yang dianggap konsisten penuh.
  static const consistencyTargetDays = 7;

  /// Apakah seluruh modul sudah pernah diselesaikan.
  static bool isEligible({
    required LearningProgress progress,
    required List<String> allModuleIds,
  }) {
    if (allModuleIds.isEmpty) return false;

    return allModuleIds.every(progress.completedModuleIds.contains);
  }

  /// Menghitung Training Record dari progres tersimpan.
  static TrainingRecord evaluate({
    required LearningProgress progress,
    required List<String> allModuleIds,
    required DateTime now,
  }) {
    final accuracy = _accuracy(progress);
    final speed = _speed(progress.patternEvents);
    final mastery = _mastery(progress.patternEvents, now);
    final practiceDays = _practiceDays(progress);
    final consistency = (practiceDays / consistencyTargetDays).clamp(0.0, 1.0);

    final score =
        (100 *
                (accuracy * accuracyWeight +
                    speed * speedWeight +
                    mastery * masteryWeight +
                    consistency * consistencyWeight))
            .round()
            .clamp(0, 100);

    return TrainingRecord(
      score: score,
      tier: tierFor(score),
      accuracy: accuracy,
      speed: speed,
      mastery: mastery,
      consistency: consistency,
      completedModules: allModuleIds
          .where(progress.completedModuleIds.contains)
          .length,
      totalModules: allModuleIds.length,
      totalSessions: progress.totalSessions,
      practiceDays: practiceDays,
      medianResponseTime: _median(_correctDurations(progress.patternEvents)),
      issuedOn: DateTime(now.year, now.month, now.day),
    );
  }

  static RecordTier tierFor(int score) {
    if (score >= 90) return RecordTier.reflex;
    if (score >= 80) return RecordTier.sharp;
    if (score >= 70) return RecordTier.steady;

    return RecordTier.completed;
  }

  /// Benar pada percobaan pertama, dihitung dari seluruh sesi tercatat.
  static double _accuracy(LearningProgress progress) {
    var correct = 0;
    var planned = 0;
    for (final record in progress.recentSessions) {
      correct += record.firstTryCorrect;
      planned += record.plannedCount;
    }

    if (planned == 0) return 0;

    return (correct / planned).clamp(0.0, 1.0);
  }

  /// Median waktu respons jawaban benar dibanding target refleks.
  static double _speed(List<PatternEvent> events) {
    final median = _median(_correctDurations(events));
    if (median == Duration.zero) return 0;

    final ratio =
        DrillSessionEngine.targetResponseTime.inMilliseconds /
        median.inMilliseconds;

    return ratio.clamp(0.0, 1.0);
  }

  /// Porsi pola yang sudah berstatus refleks pada peta kelemahan.
  static double _mastery(List<PatternEvent> events, DateTime now) {
    final insights = PatternInsights.from(events: events, now: now);
    if (insights.isEmpty) return 0;

    final solid = insights
        .where((insight) => insight.weakness == PatternWeakness.none)
        .length;

    return solid / insights.length;
  }

  /// Jumlah hari berbeda yang tercatat pernah berlatih.
  static int _practiceDays(LearningProgress progress) {
    return progress.recentSessions.map((record) => record.date).toSet().length;
  }

  static List<int> _correctDurations(List<PatternEvent> events) {
    return events
        .where((event) => event.wasCorrect)
        .map((event) => event.responseTime.inMilliseconds)
        .toList(growable: false);
  }

  static Duration _median(List<int> millis) {
    if (millis.isEmpty) return Duration.zero;

    final sorted = [...millis]..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) return Duration(milliseconds: sorted[middle]);

    return Duration(
      milliseconds: ((sorted[middle - 1] + sorted[middle]) / 2).round(),
    );
  }
}
