/// Entity modul pelajaran pada layer domain.
///
/// Bebas dari detail sumber data (JSON mock hari ini, REST API Go nanti).
class LessonModule {
  const LessonModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.isPremium,
    required this.backgroundChar,
    this.titleEn,
    this.subtitleEn,
  });

  final String id;

  /// Judul dalam Bahasa Indonesia.
  final String title;

  /// Subtitle dalam Bahasa Indonesia.
  final String subtitle;

  /// Judul Inggris; bila null, [title] dipakai sebagai cadangan.
  final String? titleEn;
  final String? subtitleEn;

  final int durationMinutes;
  final bool isPremium;

  /// Satu karakter Jepang untuk watermark transparan pada kartu.
  final String backgroundChar;

  /// Judul sesuai kode bahasa aktif, misalnya `en` atau `id`.
  String titleFor(String languageCode) =>
      languageCode == 'en' ? (titleEn ?? title) : title;

  String subtitleFor(String languageCode) =>
      languageCode == 'en' ? (subtitleEn ?? subtitle) : subtitle;
}
