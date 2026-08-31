import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/onboarding_local_data_source.dart';
import '../../domain/onboarding_preferences.dart';
import 'onboarding_controller.dart';

/// Mengubah jawaban onboarding setelah onboarding selesai.
///
/// Jawaban itu bukan keputusan sekali seumur hidup: target harian menentukan
/// panjang sesi, dan tujuan belajar menentukan materi yang didahulukan. Keduanya
/// wajar berubah — orang yang tadinya belajar untuk wisata bisa berpindah ke
/// persiapan kerja.
class PracticePreferencesEditor {
  const PracticePreferencesEditor({
    required this.dataSource,
    required this.onChanged,
  });

  final OnboardingLocalDataSource dataSource;

  /// Dipanggil setelah penyimpanan berhasil, agar layar lain memuat ulang.
  final void Function() onChanged;

  /// Memperbarui sebagian preferensi; nilai yang tidak diisi dibiarkan.
  Future<void> update({
    String? name,
    LearningGoal? goal,
    DailyTarget? dailyTarget,
  }) async {
    final current = await dataSource.read();

    // Sebelum onboarding tuntas, penyuntingan tidak berlaku: menuliskannya akan
    // menandai onboarding selesai padahal pengguna belum melewatinya.
    if (!current.isCompleted) return;

    final trimmedName = name?.trim();

    await dataSource.write(
      OnboardingPreferences(
        name: trimmedName == null || trimmedName.isEmpty
            ? current.name
            : trimmedName,
        goal: goal ?? current.goal,
        dailyTarget: dailyTarget ?? current.dailyTarget,
        isCompleted: true,
      ),
    );

    onChanged();
  }
}

final practicePreferencesEditorProvider = Provider<PracticePreferencesEditor>((
  ref,
) {
  return PracticePreferencesEditor(
    dataSource: ref.watch(onboardingDataSourceProvider),
    onChanged: () => ref.invalidate(onboardingPreferencesProvider),
  );
});
