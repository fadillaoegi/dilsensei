import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_lesson_repository.dart';
import '../../domain/entities/drill_item.dart';
import '../../domain/entities/lesson_module.dart';
import '../../domain/repositories/lesson_repository.dart';

/// Titik tukar sumber data: cukup override provider ini saat API Go siap.
final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return const MockLessonRepository();
});

final lessonModulesProvider = FutureProvider<List<LessonModule>>((ref) {
  return ref.watch(lessonRepositoryProvider).getLessonModules();
});

/// Butir drill untuk satu modul; keluarga provider agar tiap modul punya cache.
final drillItemsProvider = FutureProvider.family<List<DrillItem>, String>((
  ref,
  moduleId,
) {
  return ref.watch(lessonRepositoryProvider).getDrillItems(moduleId);
});

/// Hasil pembagian modul: satu untuk Hero Card, sisanya untuk "Peta Belajarmu".
class LessonBoard {
  const LessonBoard({required this.todayModule, required this.otherModules});

  final LessonModule? todayModule;
  final List<LessonModule> otherModules;
}

final lessonBoardProvider = Provider<AsyncValue<LessonBoard>>((ref) {
  return ref.watch(lessonModulesProvider).whenData((modules) {
    final todayModule = modules
        .where((module) => !module.isPremium)
        .firstOrNull;

    return LessonBoard(
      todayModule: todayModule,
      otherModules: modules
          .where((module) => module.id != todayModule?.id)
          .toList(growable: false),
    );
  });
});
