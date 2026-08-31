import 'package:flutter/foundation.dart';

/// Tingkat kepentingan sebuah catatan.
enum DiagnosticSeverity { info, warning, error }

/// Satu baris catatan diagnostik.
@immutable
class DiagnosticEntry {
  const DiagnosticEntry({
    required this.at,
    required this.scope,
    required this.message,
    this.level = DiagnosticSeverity.info,
    this.detail,
  });

  final DateTime at;

  /// Bagian app yang mencatat, misalnya `revenuecat`.
  final String scope;

  final String message;
  final DiagnosticSeverity level;

  /// Keterangan teknis tambahan, misalnya kode galat dari SDK.
  final String? detail;

  /// Format satu baris yang siap disalin dan ditempel.
  String format() {
    final time = at.toIso8601String().substring(11, 23);
    final tag = switch (level) {
      DiagnosticSeverity.info => 'INFO',
      DiagnosticSeverity.warning => 'WARN',
      DiagnosticSeverity.error => 'ERROR',
    };
    final suffix = detail == null ? '' : ' | $detail';

    return '$time $tag [$scope] $message$suffix';
  }
}

/// Log diagnostik dalam memori.
///
/// Dibuat karena galat di APK yang sudah dipasang tidak terlihat tanpa
/// menyambungkan logcat. Isinya dapat dibaca dan disalin dari dalam app,
/// sehingga penyebab kegagalan pembelian bisa dilaporkan apa adanya.
///
/// Sengaja **tidak** disimpan ke disk: catatan ini untuk sesi berjalan, dan
/// menuliskannya ke penyimpanan hanya menambah data yang harus dijaga.
class DiagnosticsLog extends ChangeNotifier {
  DiagnosticsLog({this.capacity = 200});

  /// Jumlah catatan terakhir yang disimpan. Yang tertua dibuang lebih dulu.
  final int capacity;

  final List<DiagnosticEntry> _entries = <DiagnosticEntry>[];

  List<DiagnosticEntry> get entries => List.unmodifiable(_entries);

  bool get isEmpty => _entries.isEmpty;

  void record(
    String scope,
    String message, {
    DiagnosticSeverity level = DiagnosticSeverity.info,
    String? detail,
  }) {
    _entries.add(
      DiagnosticEntry(
        at: DateTime.now(),
        scope: scope,
        message: message,
        level: level,
        detail: detail,
      ),
    );

    if (_entries.length > capacity) _entries.removeAt(0);

    // Tetap ikut ke logcat supaya bisa dibaca lewat `flutter logs` juga.
    debugPrint('DIAG ${_entries.last.format()}');

    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }

  /// Seluruh catatan sebagai satu teks, urut dari yang paling awal.
  String asText() => _entries.map((entry) => entry.format()).join('\n');
}

/// Menyamarkan kunci API agar tidak pernah tercatat utuh.
///
/// Prefiks tetap terlihat karena justru itu yang informatif — `test_` berarti
/// Test Store, `goog_` berarti produksi.
String maskKey(String key) {
  if (key.isEmpty) return '(kosong)';
  if (key.length <= 12) return '${key.substring(0, 5)}...';

  return '${key.substring(0, 9)}...${key.substring(key.length - 4)}';
}
