/// Catatan satu percobaan jawaban.
///
/// [responseTime] adalah inti produk ini: benar dalam 2 detik dan benar dalam
/// 9 detik diperlakukan berbeda saat menghitung skor refleks.
class DrillAttempt {
  const DrillAttempt({
    required this.itemId,
    required this.isCorrect,
    required this.responseTime,
    required this.patternIds,
    required this.isFirstTry,
  });

  final String itemId;
  final bool isCorrect;
  final Duration responseTime;

  /// Pola tata bahasa yang terlibat; saat salah, inilah pola yang dicatat lemah.
  final List<String> patternIds;

  /// Apakah ini percobaan pertama untuk butir tersebut.
  final bool isFirstTry;
}
