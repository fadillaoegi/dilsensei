/// Satu pengamatan atas sebuah pola tata bahasa pada satu percobaan jawaban.
///
/// Disimpan sebagai peristiwa bertanggal, bukan sekadar hitungan, supaya
/// kesalahan lama bisa dibuat memudar dan waktu respons ikut diperhitungkan.
class PatternEvent {
  const PatternEvent({
    required this.patternId,
    required this.date,
    required this.wasCorrect,
    required this.responseTime,
  });

  final String patternId;

  /// Tanggal percobaan, tanpa komponen waktu.
  final DateTime date;
  final bool wasCorrect;
  final Duration responseTime;
}

/// Pengamatan pola dalam satu sesi, belum bertanggal.
///
/// Tanggal ditambahkan saat progres disimpan, karena jam sistem adalah urusan
/// layer di luar mesin sesi.
class PatternObservation {
  const PatternObservation({
    required this.patternId,
    required this.wasCorrect,
    required this.responseTime,
  });

  final String patternId;
  final bool wasCorrect;
  final Duration responseTime;
}
