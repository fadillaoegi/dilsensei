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
  });

  final String id;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final bool isPremium;

  /// Satu karakter Jepang untuk watermark transparan pada kartu.
  final String backgroundChar;
}
