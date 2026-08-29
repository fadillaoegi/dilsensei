import 'dart:math' as math;

import '../entities/pattern_event.dart';
import 'drill_session_engine.dart';

/// Alasan sebuah pola dianggap belum jadi refleks.
enum PatternWeakness {
  /// Sering dijawab salah.
  accuracy,

  /// Umumnya benar, tapi jawabannya lambat.
  speed,

  /// Sudah cukup baik.
  none,
}

/// Hasil analisis satu pola tata bahasa.
class PatternInsight {
  const PatternInsight({
    required this.patternId,
    required this.riskScore,
    required this.missCount,
    required this.slowCount,
    required this.attemptCount,
    required this.medianResponseTime,
    required this.weakness,
  });

  final String patternId;

  /// 0 berarti sudah jadi refleks, 1 berarti paling perlu dilatih.
  final double riskScore;

  /// Jumlah kesalahan mentah, untuk ditampilkan ke pengguna.
  final int missCount;

  /// Jumlah jawaban benar tapi lambat.
  final int slowCount;
  final int attemptCount;
  final Duration medianResponseTime;
  final PatternWeakness weakness;

  /// Seberapa dikuasai pola ini, kebalikan dari [riskScore].
  double get mastery => (1 - riskScore).clamp(0.0, 1.0);
}

/// Menghitung peta kelemahan dari riwayat peristiwa pola.
///
/// Tiga aturan yang membentuk hasilnya:
///
/// 1. **Kesalahan lama memudar.** Bobot sebuah peristiwa berkurang setengah
///    setiap [halfLife], sehingga peta mencerminkan kondisi sekarang, bukan
///    kesalahan tiga minggu lalu.
/// 2. **Benar tapi lambat tetap dihitung.** Jawaban benar yang melewati
///    [slowThreshold] diberi penalti sebagian, karena refleks berarti cepat.
/// 3. **Sedikit data tidak langsung dianggap bencana.** Penyebut ditambah
///    [evidenceFloor], sehingga satu kesalahan pada pola yang baru dicoba
///    sekali tidak melompati pola yang salah delapan kali dari dua puluh
///    percobaan. Ketiadaan bukti berarti "belum terbukti lemah", bukan lemah.
abstract final class PatternInsights {
  /// Umur paruh bobot peristiwa.
  static const halfLife = Duration(days: 7);

  /// Batas jawaban dianggap lambat, yaitu 1,75 kali target waktu respons
  /// ([DrillSessionEngine.targetResponseTime] = 4 detik).
  static const slowThreshold = Duration(seconds: 7);

  /// Penalti untuk jawaban benar tapi lambat, relatif terhadap kesalahan penuh.
  static const slowPenalty = 0.4;

  /// Bukti minimum yang ditambahkan ke penyebut agar data tipis tidak melompat
  /// ke puncak daftar.
  static const evidenceFloor = 2.0;

  /// Ambang sebuah pola dianggap masih perlu dilatih.
  static const riskThreshold = 0.25;

  /// Menghasilkan analisis per pola, terurut dari yang paling perlu dilatih.
  static List<PatternInsight> from({
    required List<PatternEvent> events,
    required DateTime now,
  }) {
    final grouped = <String, List<PatternEvent>>{};
    for (final event in events) {
      grouped.putIfAbsent(event.patternId, () => <PatternEvent>[]).add(event);
    }

    final insights =
        grouped.entries
            .map((entry) => _analyze(entry.key, entry.value, now))
            .toList()
          ..sort((a, b) {
            final byRisk = b.riskScore.compareTo(a.riskScore);
            if (byRisk != 0) return byRisk;

            return b.attemptCount.compareTo(a.attemptCount);
          });

    return List<PatternInsight>.unmodifiable(insights);
  }

  /// Pola yang masih perlu dilatih.
  static List<PatternInsight> needingWork({
    required List<PatternEvent> events,
    required DateTime now,
  }) {
    return from(events: events, now: now)
        .where((insight) => insight.weakness != PatternWeakness.none)
        .toList(growable: false);
  }

  static PatternInsight _analyze(
    String patternId,
    List<PatternEvent> events,
    DateTime now,
  ) {
    var weightedPenalty = 0.0;
    var weightedExposure = 0.0;
    var missCount = 0;
    var slowCount = 0;
    final durations = <int>[];

    for (final event in events) {
      final weight = _decay(event.date, now);
      final isSlow = event.responseTime >= slowThreshold;

      weightedExposure += weight;
      if (!event.wasCorrect) {
        weightedPenalty += weight;
        missCount++;
      } else if (isSlow) {
        weightedPenalty += weight * slowPenalty;
        slowCount++;
      }

      if (event.wasCorrect) durations.add(event.responseTime.inMilliseconds);
    }

    final riskScore = weightedPenalty / (weightedExposure + evidenceFloor);

    return PatternInsight(
      patternId: patternId,
      riskScore: riskScore.clamp(0.0, 1.0),
      missCount: missCount,
      slowCount: slowCount,
      attemptCount: events.length,
      medianResponseTime: _median(durations),
      weakness: _weaknessFor(
        riskScore: riskScore,
        missCount: missCount,
        slowCount: slowCount,
      ),
    );
  }

  /// Bobot berkurang setengah setiap [halfLife]; peristiwa hari ini bernilai 1.
  static double _decay(DateTime date, DateTime now) {
    final days = _dateOnly(now).difference(_dateOnly(date)).inDays;
    if (days <= 0) return 1;

    return math.pow(0.5, days / halfLife.inDays).toDouble();
  }

  static PatternWeakness _weaknessFor({
    required double riskScore,
    required int missCount,
    required int slowCount,
  }) {
    if (riskScore < riskThreshold) return PatternWeakness.none;

    // Bila tidak ada kesalahan sama sekali, yang tersisa adalah soal kecepatan.
    if (missCount == 0 && slowCount > 0) return PatternWeakness.speed;

    return PatternWeakness.accuracy;
  }

  static Duration _median(List<int> millis) {
    if (millis.isEmpty) return Duration.zero;

    final sorted = [...millis]..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return Duration(milliseconds: sorted[middle]);
    }

    return Duration(
      milliseconds: ((sorted[middle - 1] + sorted[middle]) / 2).round(),
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
