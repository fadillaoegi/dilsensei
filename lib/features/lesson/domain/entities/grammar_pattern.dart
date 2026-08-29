import '../../../../l10n/app_localizations.dart';

/// Pola tata bahasa yang dilatih dan dilacak saat pengguna salah.
///
/// Pola inilah yang membentuk "peta kelemahan": kesalahan tidak dicatat sebagai
/// "salah", tapi sebagai pola apa yang belum jadi refleks.
///
/// Label-nya sengaja tidak disimpan di sini melainkan di berkas ARB, karena
/// harus mengikuti bahasa yang dipilih pengguna.
abstract final class GrammarPatterns {
  static const particlePlace = 'particle_place';
  static const particleObject = 'particle_object';
  static const particleTopic = 'particle_topic';
  static const wordOrderTime = 'word_order_time';
  static const politeForm = 'polite_form';
  static const pastForm = 'past_form';
  static const negativeForm = 'negative_form';
  static const counterWord = 'counter_word';

  static const all = <String>[
    particlePlace,
    particleObject,
    particleTopic,
    wordOrderTime,
    politeForm,
    pastForm,
    negativeForm,
    counterWord,
  ];

  /// Nama pola sesuai bahasa aktif; id yang tidak dikenal ditampilkan apa adanya
  /// supaya konten baru tidak membuat layar kosong.
  static String labelOf(AppL10n l10n, String id) => switch (id) {
    particlePlace => l10n.patternParticlePlace,
    particleObject => l10n.patternParticleObject,
    particleTopic => l10n.patternParticleTopic,
    wordOrderTime => l10n.patternWordOrderTime,
    politeForm => l10n.patternPoliteForm,
    pastForm => l10n.patternPastForm,
    negativeForm => l10n.patternNegativeForm,
    counterWord => l10n.patternCounterWord,
    _ => id,
  };
}
