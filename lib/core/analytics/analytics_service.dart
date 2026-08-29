/// Peristiwa yang dicatat aplikasi.
///
/// Daftarnya sengaja pendek dan eksplisit. Analytics dipakai untuk menjawab
/// pertanyaan pertumbuhan yang konkret — berapa orang menyelesaikan sesi
/// pertama, berapa yang melihat paywall lalu membeli — bukan untuk merekam
/// segala hal yang bisa direkam.
enum AnalyticsEvent {
  onboardingCompleted,
  sessionStarted,
  sessionCompleted,
  weakPatternDrillStarted,
  kanaChartOpened,
  paywallViewed,
  purchaseStarted,
  purchaseCompleted,
  purchaseFailed,
  restoreCompleted,
  dailyLimitReached,
  reminderEnabled,
  trainingRecordUnlocked,
  languageChanged,
}

/// Kontrak analytics.
///
/// Tidak pernah menyertakan data yang bisa mengidentifikasi orang: hanya nama
/// peristiwa dan parameter berupa angka atau kategori.
abstract interface class AnalyticsService {
  Future<void> initialize();

  Future<void> log(AnalyticsEvent event, {Map<String, Object>? parameters});

  /// Nama layar untuk melihat alur pemakaian.
  Future<void> setCurrentScreen(String screenName);
}
