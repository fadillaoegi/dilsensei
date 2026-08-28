import '../entities/drill_attempt.dart';
import '../entities/drill_item.dart';

/// Ringkasan hasil satu sesi.
class SessionSummary {
  const SessionSummary({
    required this.plannedCount,
    required this.firstTryCorrect,
    required this.totalAttempts,
    required this.medianResponseTime,
    required this.weakPatterns,
    required this.reflexScore,
  });

  final int plannedCount;

  /// Jumlah butir yang benar pada percobaan pertama.
  final int firstTryCorrect;
  final int totalAttempts;

  /// Median waktu respons dari percobaan yang benar.
  final Duration medianResponseTime;

  /// Pola tata bahasa yang salah, terurut dari paling sering.
  final List<PatternMiss> weakPatterns;

  /// Skor refleks 0–100: gabungan akurasi percobaan pertama dan kecepatan.
  final int reflexScore;

  double get accuracy => plannedCount == 0 ? 0 : firstTryCorrect / plannedCount;
}

/// Satu pola yang terlewat beserta jumlah kesalahannya.
class PatternMiss {
  const PatternMiss({required this.patternId, required this.missCount});

  final String patternId;
  final int missCount;
}

/// State sesi yang immutable; seluruh transisi lewat [DrillSessionEngine].
class DrillSessionState {
  const DrillSessionState({
    required this.queue,
    required this.attempts,
    required this.retriesLeft,
    required this.plannedCount,
  });

  /// Butir yang belum tuntas; elemen pertama adalah butir yang aktif.
  final List<DrillItem> queue;
  final List<DrillAttempt> attempts;

  /// Sisa kesempatan mengulang per butir.
  final Map<String, int> retriesLeft;

  /// Jumlah butir yang direncanakan di awal sesi.
  final int plannedCount;

  DrillItem? get currentItem => queue.isEmpty ? null : queue.first;

  bool get isFinished => queue.isEmpty;

  /// Jumlah butir yang sudah tuntas (tidak lagi ada di antrean).
  int get resolvedCount => plannedCount - _remainingUniqueCount;

  double get progress => plannedCount == 0 ? 1 : resolvedCount / plannedCount;

  int get _remainingUniqueCount => queue.map((item) => item.id).toSet().length;
}

/// Hasil satu kali penilaian jawaban.
class SubmissionResult {
  const SubmissionResult({
    required this.state,
    required this.isCorrect,
    required this.willRepeat,
    required this.missedPatternIds,
  });

  final DrillSessionState state;
  final bool isCorrect;

  /// Butir akan muncul lagi di akhir antrean sesi ini.
  final bool willRepeat;
  final List<String> missedPatternIds;
}

/// Mesin sesi drill.
///
/// Aturan intinya: butir yang salah tidak dilewati, tapi dimasukkan kembali ke
/// akhir antrean sampai berhasil atau kesempatan mengulang habis. Inilah bagian
/// "muscle memory" — pengguna tidak keluar sesi tanpa pernah benar.
abstract final class DrillSessionEngine {
  /// Batas pengulangan per butir agar sesi tidak berputar tanpa akhir.
  static const maxRetriesPerItem = 2;

  /// Target waktu respons ideal untuk perhitungan skor refleks.
  static const targetResponseTime = Duration(seconds: 4);

  static DrillSessionState start(List<DrillItem> items) {
    return DrillSessionState(
      queue: List<DrillItem>.unmodifiable(items),
      attempts: const <DrillAttempt>[],
      retriesLeft: Map<String, int>.unmodifiable(<String, int>{
        for (final item in items) item.id: maxRetriesPerItem,
      }),
      plannedCount: items.length,
    );
  }

  static SubmissionResult submit(
    DrillSessionState state, {
    required List<String> answerTokens,
    required Duration responseTime,
  }) {
    final item = state.currentItem;
    if (item == null) {
      return SubmissionResult(
        state: state,
        isCorrect: false,
        willRepeat: false,
        missedPatternIds: const <String>[],
      );
    }

    final isCorrect = _matches(answerTokens, item.answerTokens);
    final isFirstTry = !state.attempts.any(
      (attempt) => attempt.itemId == item.id,
    );
    final retriesLeft = state.retriesLeft[item.id] ?? 0;
    final willRepeat = !isCorrect && retriesLeft > 0;

    final attempts = <DrillAttempt>[
      ...state.attempts,
      DrillAttempt(
        itemId: item.id,
        isCorrect: isCorrect,
        responseTime: responseTime,
        patternIds: item.patternIds,
        isFirstTry: isFirstTry,
      ),
    ];

    final queue = <DrillItem>[...state.queue]..removeAt(0);
    if (willRepeat) {
      queue.add(item);
    }

    final updatedRetries = <String, int>{...state.retriesLeft};
    if (!isCorrect) {
      updatedRetries[item.id] = (retriesLeft - 1).clamp(0, maxRetriesPerItem);
    }

    return SubmissionResult(
      state: DrillSessionState(
        queue: List<DrillItem>.unmodifiable(queue),
        attempts: List<DrillAttempt>.unmodifiable(attempts),
        retriesLeft: Map<String, int>.unmodifiable(updatedRetries),
        plannedCount: state.plannedCount,
      ),
      isCorrect: isCorrect,
      willRepeat: willRepeat,
      missedPatternIds: isCorrect ? const <String>[] : item.patternIds,
    );
  }

  static SessionSummary summarize(DrillSessionState state) {
    final firstTryCorrect = state.attempts
        .where((attempt) => attempt.isFirstTry && attempt.isCorrect)
        .length;

    final correctDurations =
        state.attempts
            .where((attempt) => attempt.isCorrect)
            .map((attempt) => attempt.responseTime.inMilliseconds)
            .toList()
          ..sort();

    final missCounts = <String, int>{};
    for (final attempt in state.attempts.where((a) => !a.isCorrect)) {
      for (final patternId in attempt.patternIds) {
        missCounts[patternId] = (missCounts[patternId] ?? 0) + 1;
      }
    }

    final weakPatterns =
        missCounts.entries
            .map((e) => PatternMiss(patternId: e.key, missCount: e.value))
            .toList()
          ..sort((a, b) => b.missCount.compareTo(a.missCount));

    final median = _median(correctDurations);

    return SessionSummary(
      plannedCount: state.plannedCount,
      firstTryCorrect: firstTryCorrect,
      totalAttempts: state.attempts.length,
      medianResponseTime: median,
      weakPatterns: List<PatternMiss>.unmodifiable(weakPatterns),
      reflexScore: _reflexScore(
        accuracy: state.plannedCount == 0
            ? 0
            : firstTryCorrect / state.plannedCount,
        median: median,
      ),
    );
  }

  /// 70% dari akurasi percobaan pertama, 30% dari kecepatan relatif terhadap
  /// [targetResponseTime]. Jawaban yang benar tapi lambat tetap menurunkan skor.
  static int _reflexScore({
    required double accuracy,
    required Duration median,
  }) {
    if (median == Duration.zero) {
      return (accuracy * 70).round();
    }

    final speedRatio =
        targetResponseTime.inMilliseconds / median.inMilliseconds;
    final speedScore = speedRatio.clamp(0.0, 1.0);

    return (accuracy * 70 + speedScore * 30).round().clamp(0, 100);
  }

  static Duration _median(List<int> sortedMillis) {
    if (sortedMillis.isEmpty) return Duration.zero;

    final middle = sortedMillis.length ~/ 2;
    if (sortedMillis.length.isOdd) {
      return Duration(milliseconds: sortedMillis[middle]);
    }
    return Duration(
      milliseconds: ((sortedMillis[middle - 1] + sortedMillis[middle]) / 2)
          .round(),
    );
  }

  static bool _matches(List<String> answer, List<String> expected) {
    if (answer.length != expected.length) return false;
    for (var i = 0; i < answer.length; i++) {
      if (answer[i] != expected[i]) return false;
    }
    return true;
  }
}
