import '../entities/drill_item.dart';
import '../entities/lesson_module.dart';

abstract interface class LessonRepository {
  Future<List<LessonModule>> getLessonModules();

  /// Butir latihan untuk satu modul, sudah dibatasi jumlah per sesi.
  Future<List<DrillItem>> getDrillItems(String moduleId);
}
