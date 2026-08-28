import '../../domain/entities/drill_item.dart';
import '../../domain/entities/lesson_module.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasources/lesson_local_data_source.dart';

/// Implementasi sementara sampai backend Go siap.
class MockLessonRepository implements LessonRepository {
  const MockLessonRepository({
    this.dataSource = const LessonLocalDataSource(),
    this.networkDelay = const Duration(milliseconds: 900),
  });

  /// Jumlah butir maksimal per sesi agar durasinya tetap 5–10 menit.
  static const itemsPerSession = 8;

  final LessonLocalDataSource dataSource;

  /// Simulasi latensi jaringan supaya state loading benar-benar teruji.
  final Duration networkDelay;

  @override
  Future<List<LessonModule>> getLessonModules() async {
    await Future<void>.delayed(networkDelay);
    return dataSource.fetchLessonModules();
  }

  @override
  Future<List<DrillItem>> getDrillItems(String moduleId) async {
    await Future<void>.delayed(networkDelay);
    final items = await dataSource.fetchDrillItems(moduleId);

    return items.take(itemsPerSession).toList(growable: false);
  }
}
