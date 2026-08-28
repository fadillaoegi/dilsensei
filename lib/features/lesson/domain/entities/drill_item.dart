/// Satu butir latihan dalam sebuah sesi.
class DrillItem {
  const DrillItem({
    required this.id,
    required this.moduleId,
    required this.prompt,
    required this.answerTokens,
    required this.distractorTokens,
    required this.patternIds,
    this.note,
  });

  final String id;
  final String moduleId;

  /// Kalimat Indonesia yang harus disusun ulang dalam Bahasa Jepang.
  final String prompt;

  /// Urutan potongan kata yang benar.
  final List<String> answerTokens;

  /// Potongan pengecoh yang ikut ditampilkan bersama jawaban.
  final List<String> distractorTokens;

  /// Pola tata bahasa yang diuji butir ini, lihat [GrammarPatterns].
  final List<String> patternIds;

  /// Penjelasan singkat yang muncul setelah dijawab.
  final String? note;

  /// Kalimat Jepang lengkap sebagai jawaban benar.
  String get answer => answerTokens.join();

  /// Seluruh potongan yang ditampilkan ke pengguna, sudah teracak stabil
  /// berdasarkan [id] supaya urutannya tidak berubah tiap rebuild.
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
