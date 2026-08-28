import '../../domain/entities/lesson_module.dart';

/// Mapper JSON (snake_case) ke entity domain.
///
/// Kontrak key-nya disamakan dengan rencana response REST API Go.
abstract final class LessonModuleDto {
  static LessonModule fromJson(Map<String, dynamic> json) {
    return LessonModule(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      isPremium: json['is_premium'] as bool,
      backgroundChar: json['background_char'] as String,
    );
  }
}
