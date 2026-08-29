import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/certificate_rules.dart';
import 'lesson_providers.dart';
import 'progress_controller.dart';

/// Kondisi Training Record: sudah layak atau belum, beserta hasilnya.
class TrainingRecordState {
  const TrainingRecordState({
    required this.completedModules,
    required this.totalModules,
    this.record,
  });

  final int completedModules;
  final int totalModules;

  /// Terisi hanya bila seluruh modul sudah diselesaikan.
  final TrainingRecord? record;

  bool get isUnlocked => record != null;
}

/// Menghitung Training Record dari progres tersimpan dan daftar modul nyata.
///
/// Bergantung pada [lessonModulesProvider] supaya syaratnya selalu mengikuti
/// jumlah modul yang benar-benar ada, bukan angka yang dipaku.
final trainingRecordProvider = FutureProvider<TrainingRecordState>((ref) async {
  final modules = await ref.watch(lessonModulesProvider.future);
  final progress = ref.watch(progressControllerProvider);
  final now = ref.watch(nowProvider)();

  final moduleIds = modules.map((module) => module.id).toList(growable: false);
  final completed = moduleIds
      .where(progress.completedModuleIds.contains)
      .length;

  final isEligible = CertificateRules.isEligible(
    progress: progress,
    allModuleIds: moduleIds,
  );

  return TrainingRecordState(
    completedModules: completed,
    totalModules: moduleIds.length,
    record: isEligible
        ? CertificateRules.evaluate(
            progress: progress,
            allModuleIds: moduleIds,
            now: now,
          )
        : null,
  );
});
