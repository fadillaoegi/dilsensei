/// Jenis bagian pada bagan huruf.
enum KanaSectionKind {
  /// Gojūon, 46 huruf dasar.
  base,

  /// Dakuten dan handakuten, huruf bersuara.
  voiced,

  /// Yōon, gabungan dengan ゃ ゅ ょ.
  combined,
}

/// Aksara Jepang yang ditampilkan bagan.
enum KanaScript { hiragana, katakana }

/// Satu huruf beserta bacaan romaji-nya.
class KanaCell {
  const KanaCell(this.character, this.romaji);

  final String character;
  final String romaji;
}

/// Satu bagian bagan, disusun per baris agar polanya terlihat.
class KanaSection {
  const KanaSection({required this.kind, required this.rows});

  final KanaSectionKind kind;
  final List<List<KanaCell>> rows;

  /// Seluruh huruf pada bagian ini.
  List<KanaCell> get cells => rows.expand((row) => row).toList(growable: false);
}

/// Data bagan huruf, dipakai sebagai rujukan cepat sebelum sesi latihan.
///
/// Disimpan sebagai konstanta di kode, bukan aset, karena datanya tetap dan
/// tidak perlu diterjemahkan: romaji sama di semua bahasa.
abstract final class KanaChart {
  static const hiraganaBase = KanaSection(
    kind: KanaSectionKind.base,
    rows: <List<KanaCell>>[
      <KanaCell>[
        KanaCell('あ', 'a'),
        KanaCell('い', 'i'),
        KanaCell('う', 'u'),
        KanaCell('え', 'e'),
        KanaCell('お', 'o'),
      ],
      <KanaCell>[
        KanaCell('か', 'ka'),
        KanaCell('き', 'ki'),
        KanaCell('く', 'ku'),
        KanaCell('け', 'ke'),
        KanaCell('こ', 'ko'),
      ],
      <KanaCell>[
        KanaCell('さ', 'sa'),
        KanaCell('し', 'shi'),
        KanaCell('す', 'su'),
        KanaCell('せ', 'se'),
        KanaCell('そ', 'so'),
      ],
      <KanaCell>[
        KanaCell('た', 'ta'),
        KanaCell('ち', 'chi'),
        KanaCell('つ', 'tsu'),
        KanaCell('て', 'te'),
        KanaCell('と', 'to'),
      ],
      <KanaCell>[
        KanaCell('な', 'na'),
        KanaCell('に', 'ni'),
        KanaCell('ぬ', 'nu'),
        KanaCell('ね', 'ne'),
        KanaCell('の', 'no'),
      ],
      <KanaCell>[
        KanaCell('は', 'ha'),
        KanaCell('ひ', 'hi'),
        KanaCell('ふ', 'fu'),
        KanaCell('へ', 'he'),
        KanaCell('ほ', 'ho'),
      ],
      <KanaCell>[
        KanaCell('ま', 'ma'),
        KanaCell('み', 'mi'),
        KanaCell('む', 'mu'),
        KanaCell('め', 'me'),
        KanaCell('も', 'mo'),
      ],
      <KanaCell>[KanaCell('や', 'ya'), KanaCell('ゆ', 'yu'), KanaCell('よ', 'yo')],
      <KanaCell>[
        KanaCell('ら', 'ra'),
        KanaCell('り', 'ri'),
        KanaCell('る', 'ru'),
        KanaCell('れ', 're'),
        KanaCell('ろ', 'ro'),
      ],
      <KanaCell>[KanaCell('わ', 'wa'), KanaCell('を', 'wo'), KanaCell('ん', 'n')],
    ],
  );

  static const hiraganaVoiced = KanaSection(
    kind: KanaSectionKind.voiced,
    rows: <List<KanaCell>>[
      <KanaCell>[
        KanaCell('が', 'ga'),
        KanaCell('ぎ', 'gi'),
        KanaCell('ぐ', 'gu'),
        KanaCell('げ', 'ge'),
        KanaCell('ご', 'go'),
      ],
      <KanaCell>[
        KanaCell('ざ', 'za'),
        KanaCell('じ', 'ji'),
        KanaCell('ず', 'zu'),
        KanaCell('ぜ', 'ze'),
        KanaCell('ぞ', 'zo'),
      ],
      <KanaCell>[
        KanaCell('だ', 'da'),
        KanaCell('ぢ', 'ji'),
        KanaCell('づ', 'zu'),
        KanaCell('で', 'de'),
        KanaCell('ど', 'do'),
      ],
      <KanaCell>[
        KanaCell('ば', 'ba'),
        KanaCell('び', 'bi'),
        KanaCell('ぶ', 'bu'),
        KanaCell('べ', 'be'),
        KanaCell('ぼ', 'bo'),
      ],
      <KanaCell>[
        KanaCell('ぱ', 'pa'),
        KanaCell('ぴ', 'pi'),
        KanaCell('ぷ', 'pu'),
        KanaCell('ぺ', 'pe'),
        KanaCell('ぽ', 'po'),
      ],
    ],
  );

  static const hiraganaCombined = KanaSection(
    kind: KanaSectionKind.combined,
    rows: <List<KanaCell>>[
      <KanaCell>[
        KanaCell('きゃ', 'kya'),
        KanaCell('きゅ', 'kyu'),
        KanaCell('きょ', 'kyo'),
      ],
      <KanaCell>[
        KanaCell('しゃ', 'sha'),
        KanaCell('しゅ', 'shu'),
        KanaCell('しょ', 'sho'),
      ],
      <KanaCell>[
        KanaCell('ちゃ', 'cha'),
        KanaCell('ちゅ', 'chu'),
        KanaCell('ちょ', 'cho'),
      ],
      <KanaCell>[
        KanaCell('にゃ', 'nya'),
        KanaCell('にゅ', 'nyu'),
        KanaCell('にょ', 'nyo'),
      ],
      <KanaCell>[
        KanaCell('ひゃ', 'hya'),
        KanaCell('ひゅ', 'hyu'),
        KanaCell('ひょ', 'hyo'),
      ],
      <KanaCell>[
        KanaCell('みゃ', 'mya'),
        KanaCell('みゅ', 'myu'),
        KanaCell('みょ', 'myo'),
      ],
      <KanaCell>[
        KanaCell('りゃ', 'rya'),
        KanaCell('りゅ', 'ryu'),
        KanaCell('りょ', 'ryo'),
      ],
      <KanaCell>[
        KanaCell('ぎゃ', 'gya'),
        KanaCell('ぎゅ', 'gyu'),
        KanaCell('ぎょ', 'gyo'),
      ],
      <KanaCell>[
        KanaCell('じゃ', 'ja'),
        KanaCell('じゅ', 'ju'),
        KanaCell('じょ', 'jo'),
      ],
      <KanaCell>[
        KanaCell('びゃ', 'bya'),
        KanaCell('びゅ', 'byu'),
        KanaCell('びょ', 'byo'),
      ],
      <KanaCell>[
        KanaCell('ぴゃ', 'pya'),
        KanaCell('ぴゅ', 'pyu'),
        KanaCell('ぴょ', 'pyo'),
      ],
    ],
  );

  static const katakanaBase = KanaSection(
    kind: KanaSectionKind.base,
    rows: <List<KanaCell>>[
      <KanaCell>[
        KanaCell('ア', 'a'),
        KanaCell('イ', 'i'),
        KanaCell('ウ', 'u'),
        KanaCell('エ', 'e'),
        KanaCell('オ', 'o'),
      ],
      <KanaCell>[
        KanaCell('カ', 'ka'),
        KanaCell('キ', 'ki'),
        KanaCell('ク', 'ku'),
        KanaCell('ケ', 'ke'),
        KanaCell('コ', 'ko'),
      ],
      <KanaCell>[
        KanaCell('サ', 'sa'),
        KanaCell('シ', 'shi'),
        KanaCell('ス', 'su'),
        KanaCell('セ', 'se'),
        KanaCell('ソ', 'so'),
      ],
      <KanaCell>[
        KanaCell('タ', 'ta'),
        KanaCell('チ', 'chi'),
        KanaCell('ツ', 'tsu'),
        KanaCell('テ', 'te'),
        KanaCell('ト', 'to'),
      ],
      <KanaCell>[
        KanaCell('ナ', 'na'),
        KanaCell('ニ', 'ni'),
        KanaCell('ヌ', 'nu'),
        KanaCell('ネ', 'ne'),
        KanaCell('ノ', 'no'),
      ],
      <KanaCell>[
        KanaCell('ハ', 'ha'),
        KanaCell('ヒ', 'hi'),
        KanaCell('フ', 'fu'),
        KanaCell('ヘ', 'he'),
        KanaCell('ホ', 'ho'),
      ],
      <KanaCell>[
        KanaCell('マ', 'ma'),
        KanaCell('ミ', 'mi'),
        KanaCell('ム', 'mu'),
        KanaCell('メ', 'me'),
        KanaCell('モ', 'mo'),
      ],
      <KanaCell>[KanaCell('ヤ', 'ya'), KanaCell('ユ', 'yu'), KanaCell('ヨ', 'yo')],
      <KanaCell>[
        KanaCell('ラ', 'ra'),
        KanaCell('リ', 'ri'),
        KanaCell('ル', 'ru'),
        KanaCell('レ', 're'),
        KanaCell('ロ', 'ro'),
      ],
      <KanaCell>[KanaCell('ワ', 'wa'), KanaCell('ヲ', 'wo'), KanaCell('ン', 'n')],
    ],
  );

  static const katakanaVoiced = KanaSection(
    kind: KanaSectionKind.voiced,
    rows: <List<KanaCell>>[
      <KanaCell>[
        KanaCell('ガ', 'ga'),
        KanaCell('ギ', 'gi'),
        KanaCell('グ', 'gu'),
        KanaCell('ゲ', 'ge'),
        KanaCell('ゴ', 'go'),
      ],
      <KanaCell>[
        KanaCell('ザ', 'za'),
        KanaCell('ジ', 'ji'),
        KanaCell('ズ', 'zu'),
        KanaCell('ゼ', 'ze'),
        KanaCell('ゾ', 'zo'),
      ],
      <KanaCell>[
        KanaCell('ダ', 'da'),
        KanaCell('ヂ', 'ji'),
        KanaCell('ヅ', 'zu'),
        KanaCell('デ', 'de'),
        KanaCell('ド', 'do'),
      ],
      <KanaCell>[
        KanaCell('バ', 'ba'),
        KanaCell('ビ', 'bi'),
        KanaCell('ブ', 'bu'),
        KanaCell('ベ', 'be'),
        KanaCell('ボ', 'bo'),
      ],
      <KanaCell>[
        KanaCell('パ', 'pa'),
        KanaCell('ピ', 'pi'),
        KanaCell('プ', 'pu'),
        KanaCell('ペ', 'pe'),
        KanaCell('ポ', 'po'),
      ],
    ],
  );

  static const katakanaCombined = KanaSection(
    kind: KanaSectionKind.combined,
    rows: <List<KanaCell>>[
      <KanaCell>[
        KanaCell('キャ', 'kya'),
        KanaCell('キュ', 'kyu'),
        KanaCell('キョ', 'kyo'),
      ],
      <KanaCell>[
        KanaCell('シャ', 'sha'),
        KanaCell('シュ', 'shu'),
        KanaCell('ショ', 'sho'),
      ],
      <KanaCell>[
        KanaCell('チャ', 'cha'),
        KanaCell('チュ', 'chu'),
        KanaCell('チョ', 'cho'),
      ],
      <KanaCell>[
        KanaCell('ニャ', 'nya'),
        KanaCell('ニュ', 'nyu'),
        KanaCell('ニョ', 'nyo'),
      ],
      <KanaCell>[
        KanaCell('ヒャ', 'hya'),
        KanaCell('ヒュ', 'hyu'),
        KanaCell('ヒョ', 'hyo'),
      ],
      <KanaCell>[
        KanaCell('ミャ', 'mya'),
        KanaCell('ミュ', 'myu'),
        KanaCell('ミョ', 'myo'),
      ],
      <KanaCell>[
        KanaCell('リャ', 'rya'),
        KanaCell('リュ', 'ryu'),
        KanaCell('リョ', 'ryo'),
      ],
      <KanaCell>[
        KanaCell('ギャ', 'gya'),
        KanaCell('ギュ', 'gyu'),
        KanaCell('ギョ', 'gyo'),
      ],
      <KanaCell>[
        KanaCell('ジャ', 'ja'),
        KanaCell('ジュ', 'ju'),
        KanaCell('ジョ', 'jo'),
      ],
      <KanaCell>[
        KanaCell('ビャ', 'bya'),
        KanaCell('ビュ', 'byu'),
        KanaCell('ビョ', 'byo'),
      ],
      <KanaCell>[
        KanaCell('ピャ', 'pya'),
        KanaCell('ピュ', 'pyu'),
        KanaCell('ピョ', 'pyo'),
      ],
    ],
  );

  /// Bagian-bagian untuk satu aksara, berurutan dari dasar ke gabungan.
  static List<KanaSection> sectionsFor(KanaScript script) {
    return switch (script) {
      KanaScript.hiragana => const <KanaSection>[
        hiraganaBase,
        hiraganaVoiced,
        hiraganaCombined,
      ],
      KanaScript.katakana => const <KanaSection>[
        katakanaBase,
        katakanaVoiced,
        katakanaCombined,
      ],
    };
  }
}
