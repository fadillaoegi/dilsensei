// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppL10nId extends AppL10n {
  AppL10nId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'DilSensei';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get commonNext => 'Lanjut';

  @override
  String get commonBack => 'Kembali';

  @override
  String get commonDone => 'Selesai';

  @override
  String get commonClear => 'Hapus';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonRetry => 'Coba Lagi';

  @override
  String get commonReload => 'Muat Ulang';

  @override
  String get commonSeePro => 'Lihat paket Pro';

  @override
  String get onboardingNameTitle => 'Kita mulai dari\nnamamu';

  @override
  String get onboardingNameSubtitle =>
      'Dipakai untuk menyapamu setiap kali membuka latihan.';

  @override
  String get onboardingNameHint => 'Nama panggilan';

  @override
  String get onboardingGoalTitle => 'Kenapa belajar\nbahasa Jepang?';

  @override
  String get onboardingGoalSubtitle =>
      'Ini menentukan frasa mana yang kamu latih lebih dulu.';

  @override
  String get onboardingTargetTitle => 'Berapa menit\nsehari?';

  @override
  String get onboardingTargetSubtitle =>
      'Refleks tumbuh dari rutinitas pendek yang tidak bolong.';

  @override
  String get onboardingStart => 'Mulai Berlatih';

  @override
  String get goalWorkLabel => 'Untuk kerja';

  @override
  String get goalWorkDescription => 'Frasa kantor, laporan, dan komunikasi tim';

  @override
  String get goalTravelLabel => 'Untuk jalan-jalan';

  @override
  String get goalTravelDescription => 'Bertanya arah, memesan, dan berbelanja';

  @override
  String get goalCultureLabel => 'Untuk anime & budaya';

  @override
  String get goalCultureDescription =>
      'Percakapan sehari-hari yang terasa alami';

  @override
  String get goalExamLabel => 'Untuk ujian';

  @override
  String get goalExamDescription =>
      'Pola tata bahasa yang sering keluar di JLPT';

  @override
  String get targetLightLabel => 'Ringan';

  @override
  String get targetLightDescription => 'Cukup untuk menjaga streak';

  @override
  String get targetSteadyLabel => 'Mantap';

  @override
  String get targetSteadyDescription => 'Paling banyak dipilih';

  @override
  String get targetIntenseLabel => 'Serius';

  @override
  String get targetIntenseDescription => 'Untuk yang sedang dikejar tenggat';

  @override
  String targetMinutes(int minutes, String label) {
    return '$minutes menit · $label';
  }

  @override
  String homeGreeting(String name) {
    return 'Konnichiwa, $name!';
  }

  @override
  String get homeGreetingFallbackName => 'Sensei';

  @override
  String get homeSubtitle => 'Waktunya melatih memori ototmu';

  @override
  String homeStreakSemantics(int days) {
    return 'Streak $days hari';
  }

  @override
  String get homeTodayLabel => 'MODUL HARI INI';

  @override
  String homeStartSession(int minutes) {
    return 'Mulai Sesi ($minutes Menit)';
  }

  @override
  String get homeRoadmapTitle => 'Peta Belajarmu';

  @override
  String get homeLoading => 'Menyiapkan sesi latihanmu...';

  @override
  String get homeErrorTitle => 'Materi belum bisa dimuat';

  @override
  String get homeErrorBody => 'Periksa koneksimu, lalu coba lagi sebentar.';

  @override
  String homeMinutesShort(int minutes) {
    return '$minutes mnt';
  }

  @override
  String get homePremiumSemantics => 'Modul premium, perlu langganan';

  @override
  String get homeInsightsTooltip => 'Peta Kelemahan';

  @override
  String get homeSettingsTooltip => 'Pengaturan';

  @override
  String get dailyLimitTitle => 'Sesi hari ini sudah selesai';

  @override
  String get dailyLimitBody =>
      'Versi gratis memberi satu sesi setiap hari. Refleks tumbuh dari pengulangan, dan Pro membuka sesi sebanyak yang kamu mau — termasuk sesi yang disusun dari pola kelemahanmu.';

  @override
  String get dailyLimitLater => 'Besok lagi';

  @override
  String get sessionAssembleLabel => 'SUSUN DALAM BAHASA JEPANG';

  @override
  String get sessionParticleLabel => 'LENGKAPI PARTIKELNYA';

  @override
  String get sessionTransformLabel => 'UBAH BENTUKNYA';

  @override
  String get sessionCanvasHint => 'Ketuk potongan kata untuk menyusun jawaban';

  @override
  String get sessionCheck => 'Periksa';

  @override
  String get sessionContinue => 'Lanjut';

  @override
  String get sessionSeeResult => 'Lihat Hasil';

  @override
  String get sessionExitTooltip => 'Keluar sesi';

  @override
  String get sessionLoading => 'Menyiapkan butir latihan...';

  @override
  String get sessionEmpty => 'Butir latihan untuk modul ini belum tersedia.';

  @override
  String get sessionErrorTitle => 'Latihan belum bisa dimuat';

  @override
  String get feedbackCorrect => 'Tepat.';

  @override
  String get feedbackWrongRepeat =>
      'Belum tepat — butir ini muncul lagi nanti.';

  @override
  String get feedbackWrongMovedOn => 'Belum tepat. Simpan untuk sesi besok.';

  @override
  String feedbackPatternToPractise(String patterns) {
    return 'Pola yang perlu dilatih: $patterns';
  }

  @override
  String get summaryTitle => 'Sesi selesai';

  @override
  String get summaryReflexScore => 'skor refleks';

  @override
  String get summaryFirstTry => 'Benar sekali coba';

  @override
  String get summaryResponseTime => 'Waktu respons';

  @override
  String summarySeconds(String seconds) {
    return '$seconds dtk';
  }

  @override
  String get summaryNoData => '—';

  @override
  String get summaryWeakTitle => 'Pola yang belum jadi refleks';

  @override
  String get summaryClean => 'Bersih.';

  @override
  String get summaryCleanBody =>
      'Tidak ada pola yang salah di sesi ini. Modul berikutnya akan menaikkan tempo.';

  @override
  String get summaryDrillWeak => 'Latih pola lemah sekarang';

  @override
  String get insightsTitle => 'Peta Kelemahan';

  @override
  String get insightsTotalSessions => 'Total sesi';

  @override
  String get insightsBestScore => 'Skor terbaik';

  @override
  String get insightsPatternsTitle => 'Pola yang paling sering meleset';

  @override
  String get insightsPatternsSubtitle =>
      'Kesalahan terbaru berbobot lebih besar daripada yang lama, dan jawaban benar tapi lambat tetap dihitung.';

  @override
  String insightsReasonAccuracy(int count) {
    return '$count kali salah';
  }

  @override
  String insightsReasonSlow(int count) {
    return '$count kali lambat';
  }

  @override
  String get insightsReasonSolid => 'Sudah mantap';

  @override
  String insightsMastery(int percent) {
    return '$percent% dikuasai';
  }

  @override
  String get insightsStrongTitle => 'Sudah jadi refleks';

  @override
  String get insightsNoPatterns =>
      'Belum ada pola yang salah. Selesaikan beberapa sesi lagi untuk melihat petanya.';

  @override
  String get insightsProgressTitle => 'Perkembangan skor refleks';

  @override
  String get insightsHistoryLocked => 'Riwayat perkembangan terbuka di Pro.';

  @override
  String get insightsHistoryEmpty =>
      'Riwayat akan muncul setelah sesi pertamamu.';

  @override
  String insightsHiddenPatterns(int count) {
    return '$count pola lain masih tersembunyi di versi gratis.';
  }

  @override
  String get insightsEmptyTitle => 'Belum ada yang bisa dipetakan';

  @override
  String get insightsEmptyBody =>
      'Selesaikan satu sesi latihan, lalu kembali ke sini untuk melihat pola mana yang belum jadi refleks.';

  @override
  String insightsAccuracy(int percent) {
    return '$percent% tepat';
  }

  @override
  String insightsMissCount(int count) {
    return '${count}x';
  }

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsFreePlan => 'Versi gratis';

  @override
  String get settingsProActive => 'Akses Pro aktif';

  @override
  String settingsDailyTarget(int minutes) {
    return 'Target harian: $minutes menit';
  }

  @override
  String settingsSessionsToday(int count) {
    return 'Sesi hari ini: $count';
  }

  @override
  String get settingsSectionLanguage => 'Bahasa';

  @override
  String get settingsSectionPractice => 'Latihan';

  @override
  String get settingsSectionAppearance => 'Tampilan';

  @override
  String get themeSystem => 'Ikuti perangkat';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get settingsThemeSubtitle => 'Sedang aktif';

  @override
  String get settingsSectionSubscription => 'Langganan';

  @override
  String get settingsSectionLegal => 'Legal';

  @override
  String get settingsSectionDevelopment => 'Pengembangan';

  @override
  String get settingsLanguageSubtitle => 'Antarmuka dan perintah latihan';

  @override
  String get settingsRestore => 'Restore Purchases';

  @override
  String get settingsRestoreSubtitle =>
      'Pulihkan langganan setelah ganti perangkat';

  @override
  String get settingsManage => 'Kelola langganan';

  @override
  String get settingsManageSubtitle => 'Ubah atau batalkan lewat Google Play';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsTerms => 'Terms of Use';

  @override
  String get settingsDevToggle => 'DEV: Paksa akses Pro';

  @override
  String get settingsDevToggleBody =>
      'Membuka semua modul dan sesi tanpa pembelian, hanya untuk pengujian. Tidak pernah tampil di build release.';

  @override
  String get settingsRestoreSuccess => 'Langganan berhasil dipulihkan.';

  @override
  String get settingsRestoreEmpty => 'Tidak ada langganan untuk dipulihkan.';

  @override
  String settingsCannotOpen(String url) {
    return 'Tidak bisa membuka $url';
  }

  @override
  String get paywallHeadline => 'Buka\nPotensi\nPenuhmu';

  @override
  String get paywallBody =>
      'Jangan biarkan memori ototmu terputus. Latih pola yang masih membuatmu ragu, sampai bahasa Jepang keluar tanpa kamu pikirkan.';

  @override
  String get paywallBenefitModules =>
      'Seluruh modul dan sesi tanpa batas harian';

  @override
  String get paywallBenefitMap =>
      'Peta pola kelemahan lengkap, bukan ringkasan';

  @override
  String get paywallBenefitAuto =>
      'Sesi otomatis dari pola yang belum jadi refleks';

  @override
  String get paywallBenefitHistory =>
      'Riwayat skor refleks dan perkembangan mingguan';

  @override
  String get paywallCta => 'Mulai Langganan';

  @override
  String get paywallRestore => 'Restore Purchases';

  @override
  String get paywallDisclosure =>
      'Langganan diperpanjang otomatis sampai dibatalkan. Pembatalan dilakukan lewat pengaturan akun store.';

  @override
  String get paywallPricesLoading => 'Mengambil harga dari store...';

  @override
  String get paywallPricesErrorTitle => 'Harga belum bisa ditampilkan';

  @override
  String get paywallPricesErrorBody =>
      'Periksa koneksimu, lalu muat ulang daftar paket.';

  @override
  String get paywallPurchaseSuccess => 'Langganan aktif. Selamat berlatih!';

  @override
  String get paywallPurchaseFailed => 'Pembelian gagal.';

  @override
  String get paywallTestStore =>
      'MODE TEST STORE — pembelian tidak menagih uang';

  @override
  String get paywallRecommended => 'HEMAT';

  @override
  String paywallSavePercent(int percent) {
    return 'Hemat $percent%';
  }

  @override
  String get planPeriodWeekly => '/ minggu';

  @override
  String get planPeriodMonthly => '/ bulan';

  @override
  String get planPeriodAnnual => '/ tahun';

  @override
  String get planPeriodLifetime => 'sekali bayar';

  @override
  String get planTitleWeekly => 'Paket Mingguan';

  @override
  String get planTitleMonthly => 'Paket Bulanan';

  @override
  String get planTitleAnnual => 'Paket Tahunan';

  @override
  String get planTitleLifetime => 'Akses Selamanya';

  @override
  String planTrialFree(int count, String unit) {
    return '$count $unit gratis';
  }

  @override
  String get planUnitDay => 'hari';

  @override
  String get planUnitWeek => 'minggu';

  @override
  String get planUnitMonth => 'bulan';

  @override
  String get planUnitYear => 'tahun';

  @override
  String get patternParticlePlace => 'Partikel tempat';

  @override
  String get patternParticleObject => 'Partikel objek';

  @override
  String get patternParticleTopic => 'Partikel topik';

  @override
  String get patternWordOrderTime => 'Urutan keterangan waktu';

  @override
  String get patternPoliteForm => 'Bentuk sopan';

  @override
  String get patternPastForm => 'Bentuk lampau';

  @override
  String get patternNegativeForm => 'Bentuk negatif';

  @override
  String get patternCounterWord => 'Kata bantu bilangan';

  @override
  String get kanaSectionTitle => 'Segarkan hurufnya dulu';

  @override
  String get kanaSectionSubtitle => 'Rujukan gratis, tanpa perlu sesi';

  @override
  String get kanaFreeBadge => 'GRATIS';

  @override
  String get kanaHiragana => 'Hiragana';

  @override
  String get kanaKatakana => 'Katakana';

  @override
  String kanaLetterCount(int count) {
    return '$count huruf';
  }

  @override
  String get kanaSectionBase => 'Gojūon · 46 huruf dasar';

  @override
  String get kanaSectionVoiced => 'Dakuten · huruf bersuara';

  @override
  String get kanaSectionCombined => 'Yōon · huruf gabungan';

  @override
  String get kanaUsageTitle => 'Dipakai kapan?';

  @override
  String get kanaHiraganaUsage =>
      'Hiragana adalah aksara dasar. Dipakai untuk kata asli Jepang, untuk partikel seperti は dan を, serta untuk akhiran kata kerja yang bentuknya terus berubah. Kalau kamu belum tahu kanji sebuah kata, hiragana adalah pilihan aman yang tetap dipahami semua orang.';

  @override
  String get kanaKatakanaUsage =>
      'Katakana menandai kata yang datang dari luar bahasa Jepang — コーヒー untuk kopi, パソコン untuk komputer, dan nama asing termasuk namamu. Kamu juga akan menemuinya di menu, kemasan, dan papan petunjuk, serta dipakai untuk penekanan seperti fungsi huruf miring dalam Bahasa Indonesia.';

  @override
  String get kanaTipTitle => 'Cara membacanya lebih cepat';

  @override
  String get kanaTipBody =>
      'Baca mendatar per baris, jangan menurun: konsonannya tetap, yang berganti hanya vokalnya. Begitu satu baris terasa otomatis, lanjut ke baris berikutnya alih-alih menghafal seluruh bagan sekaligus.';

  @override
  String homeGreetingMorning(String name) {
    return 'Ohayou, $name!';
  }

  @override
  String homeGreetingMidday(String name) {
    return 'Konnichiwa, $name!';
  }

  @override
  String homeGreetingAfternoon(String name) {
    return 'Konnichiwa, $name!';
  }

  @override
  String homeGreetingEvening(String name) {
    return 'Konbanwa, $name!';
  }

  @override
  String get homeSubtitleMorning =>
      'Sesi singkat sekarang menentukan ritme harimu';

  @override
  String get homeSubtitleMidday =>
      'Sepuluh menit di antara pekerjaan sudah cukup';

  @override
  String get homeSubtitleAfternoon =>
      'Kalahkan kantuk sore dengan satu drill cepat';

  @override
  String get homeSubtitleEvening =>
      'Tutup hari dengan mengunci apa yang sudah dilatih';

  @override
  String get settingsSectionReminder => 'Pengingat harian';

  @override
  String get settingsReminderToggle => 'Ingatkan saya berlatih';

  @override
  String get settingsReminderToggleBody =>
      'Satu notifikasi sehari, otomatis dilewati kalau kamu sudah berlatih.';

  @override
  String get settingsReminderTime => 'Jam pengingat';

  @override
  String settingsReminderTimeValue(String time) {
    return 'Setiap hari pukul $time';
  }

  @override
  String get settingsReminderPermissionDenied =>
      'Notifikasi DilSensei sedang dimatikan. Aktifkan dulu di pengaturan sistem.';

  @override
  String reminderTitleWeakAccuracy(String pattern) {
    return '$pattern masih sering meleset';
  }

  @override
  String get reminderBodyWeakAccuracy =>
      'Tiga menit cukup untuk memperbaikinya. Mau latih pola itu saja?';

  @override
  String reminderTitleWeakSpeed(String pattern) {
    return '$pattern benar tapi lambat';
  }

  @override
  String get reminderBodyWeakSpeed =>
      'Benar belum berarti refleks. Satu sesi singkat akan mempercepatnya.';

  @override
  String get reminderTitleStreak => 'Streak-mu sedang menunggu';

  @override
  String get reminderBodyStreak =>
      'Satu sesi cukup untuk menjaganya. Lebih cepat daripada scrolling.';

  @override
  String get reminderTitleFirst => 'Siap untuk latihan pertamamu?';

  @override
  String get reminderBodyFirst =>
      'Lima menit, satu modul, dan ritmenya sudah mulai terasa.';

  @override
  String get recordUnlockedCta => 'Lihat Training Record-mu';

  @override
  String get recordEntryTitle => 'Training Record';

  @override
  String get recordEntrySubtitle => 'Bukti bahwa kamu menuntaskan semua modul';

  @override
  String recordEntryLocked(int completed, int total) {
    return '$completed dari $total modul selesai';
  }

  @override
  String get purchaseErrorPlanNotFound => 'Paket itu sedang tidak tersedia.';

  @override
  String get purchaseErrorNotActive => 'Langganan belum aktif.';

  @override
  String get purchaseErrorStore => 'Store tidak bisa menyelesaikan pembelian.';

  @override
  String get purchaseErrorNotConfigured =>
      'Pembelian belum tersedia di build ini.';

  @override
  String get updateAvailableTitle => 'Pembaruan tersedia';

  @override
  String get updateAvailableBody =>
      'Versi DilSensei yang lebih baru sudah ada di Google Play.';

  @override
  String get updateDialogAction => 'Perbarui sekarang';

  @override
  String get updateDismiss => 'Nanti';

  @override
  String get updateDownloadingTitle => 'Mengunduh pembaruan';

  @override
  String get updateDownloadingBody =>
      'Kamu bisa tetap berlatih sambil menunggu.';

  @override
  String get updateReadyTitle => 'Pembaruan siap';

  @override
  String get updateReadyBody =>
      'Mulai ulang app untuk menyelesaikan pemasangan.';

  @override
  String get updateReadyAction => 'Mulai ulang';

  @override
  String get updateFailedTitle => 'Pembaruan tidak bisa dimulai';

  @override
  String get updateFailedBody =>
      'Buka DilSensei di Google Play untuk memperbarui manual.';

  @override
  String get updateFailedAction => 'Buka Google Play';

  @override
  String get diagnosticsTitle => 'Diagnostik';

  @override
  String get diagnosticsSubtitle => 'Catatan teknis untuk sesi ini';

  @override
  String get diagnosticsCopy => 'Salin semua';

  @override
  String get diagnosticsClear => 'Bersihkan';

  @override
  String get diagnosticsCopied => 'Log disalin ke papan klip';

  @override
  String get diagnosticsEmpty =>
      'Belum ada catatan. Buka paywall untuk merekam aktivitas langganan.';

  @override
  String get practicePreferencesTitle => 'Preferensi latihan';

  @override
  String get practicePreferencesSubtitle =>
      'Ubah kapan saja bila alasanmu belajar berubah. Progres dan streak tetap tersimpan.';

  @override
  String get practicePreferencesEntry => 'Tujuan & target harian';

  @override
  String get practicePreferencesError => 'Tidak bisa memuat preferensimu.';
}
