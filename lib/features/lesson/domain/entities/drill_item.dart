/// Tipe latihan dalam satu sesi.
///
/// Ketiganya dinilai oleh mesin yang sama: jawaban selalu berupa urutan token.
/// Bedanya hanya berapa token yang diminta dan bagaimana pertanyaan disajikan.
enum DrillType {
  /// Menyusun kalimat utuh dari potongan kata.
  assembleSentence,

  /// Memilih satu partikel yang tepat untuk mengisi rumpang.
  chooseParticle,

  /// Mengubah bentuk kata sesuai instruksi, misalnya ke bentuk lampau sopan.
  transformForm;

  /// Butir dengan satu jawaban tunggal disajikan sebagai pilihan, bukan susunan.
  bool get isSingleChoice => this != DrillType.assembleSentence;
}

/// Satu butir latihan dalam sebuah sesi.
class DrillItem {
  const DrillItem({
    required this.id,
    required this.moduleId,
    required this.prompt,
    required this.answerTokens,
    required this.distractorTokens,
    required this.patternIds,
    this.type = DrillType.assembleSentence,
    this.questionText,
    this.instruction,
    this.note,
    this.promptEn,
    this.instructionEn,
    this.noteEn,
  });

  final String id;
  final String moduleId;

  /// Arti dalam Bahasa Indonesia. Selalu ada, apa pun tipenya.
  final String prompt;

  /// Versi Inggris; bila null, versi Indonesia dipakai sebagai cadangan.
  final String? promptEn;
  final String? instructionEn;
  final String? noteEn;

  /// Urutan token jawaban yang benar. Untuk tipe pilihan, panjangnya satu.
  final List<String> answerTokens;

  /// Token pengecoh yang ikut ditampilkan bersama jawaban.
  final List<String> distractorTokens;

  /// Pola tata bahasa yang diuji butir ini, lihat [GrammarPatterns].
  final List<String> patternIds;

  final DrillType type;

  /// Teks Jepang yang ditampilkan sebagai pertanyaan.
  ///
  /// Untuk [DrillType.chooseParticle] memuat penanda rumpang `＿`. Untuk
  /// [DrillType.transformForm] memuat bentuk dasar yang harus diubah.
  final String? questionText;

  /// Instruksi tambahan, dipakai terutama oleh [DrillType.transformForm].
  final String? instruction;

  /// Penjelasan singkat yang muncul setelah dijawab.
  final String? note;

  /// Penanda rumpang pada [questionText].
  static const blankMarker = '＿';

  /// Arti sesuai kode bahasa aktif, misalnya `en` atau `id`.
  String promptFor(String languageCode) =>
      languageCode == 'en' ? (promptEn ?? prompt) : prompt;

  String? instructionFor(String languageCode) =>
      languageCode == 'en' ? (instructionEn ?? instruction) : instruction;

  String? noteFor(String languageCode) =>
      languageCode == 'en' ? (noteEn ?? note) : note;

  /// Kalimat Jepang lengkap sebagai jawaban benar.
  String get answer => switch (type) {
    DrillType.assembleSentence => answerTokens.join(),
    _ =>
      questionText?.replaceFirst(blankMarker, answerTokens.join()) ??
          answerTokens.join(),
  };

  /// Seluruh token yang ditampilkan ke pengguna, teracak stabil berdasarkan
  /// [id] supaya urutannya tidak berubah tiap rebuild.
  List<String> get shuffledTokens {
    final tokens = <String>[...answerTokens, ...distractorTokens];
    tokens.sort((a, b) {
      final left = '$id$a'.hashCode;
      final right = '$id$b'.hashCode;
      return left.compareTo(right);
    });
    return List<String>.unmodifiable(tokens);
  }
}
