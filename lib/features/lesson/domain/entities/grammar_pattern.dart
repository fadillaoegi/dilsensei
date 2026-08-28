/// Pola tata bahasa yang dilatih dan dilacak saat pengguna salah.
///
/// Pola inilah yang nanti membentuk "peta kelemahan": kesalahan tidak dicatat
/// sebagai "salah", tapi sebagai pola apa yang belum jadi refleks.
class GrammarPattern {
  const GrammarPattern({required this.id, required this.label});

  final String id;

  /// Nama pola dalam Bahasa Indonesia, dipakai langsung di UI.
  final String label;
}

/// Katalog pola yang dipakai konten drill saat ini.
abstract final class GrammarPatterns {
  static const particlePlace = GrammarPattern(
    id: 'particle_place',
    label: 'Partikel tempat',
  );
  static const particleObject = GrammarPattern(
    id: 'particle_object',
    label: 'Partikel objek',
  );
  static const particleTopic = GrammarPattern(
    id: 'particle_topic',
    label: 'Partikel topik',
  );
  static const wordOrderTime = GrammarPattern(
    id: 'word_order_time',
    label: 'Urutan keterangan waktu',
  );
  static const politeForm = GrammarPattern(
    id: 'polite_form',
    label: 'Bentuk sopan',
  );
  static const pastForm = GrammarPattern(
    id: 'past_form',
    label: 'Bentuk lampau',
  );
  static const negativeForm = GrammarPattern(
    id: 'negative_form',
    label: 'Bentuk negatif',
  );
  static const counterWord = GrammarPattern(
    id: 'counter_word',
    label: 'Kata bantu bilangan',
  );

  static const all = <GrammarPattern>[
    particlePlace,
    particleObject,
    particleTopic,
    wordOrderTime,
    politeForm,
    pastForm,
    negativeForm,
    counterWord,
  ];

  static final _byId = <String, GrammarPattern>{
    for (final pattern in all) pattern.id: pattern,
  };

  /// Mengembalikan label pola, atau id itu sendiri bila pola tidak dikenal.
  static String labelOf(String id) => _byId[id]?.label ?? id;
}
