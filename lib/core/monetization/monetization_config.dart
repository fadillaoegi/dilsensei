import 'package:flutter/foundation.dart';

/// Konfigurasi RevenueCat dan tautan legal.
///
/// Pemilihan key bersifat otomatis menurut mode build:
///
/// | Build            | Key yang dipakai            |
/// | ---------------- | --------------------------- |
/// | debug / profile  | `test_...` (Test Store)     |
/// | release / AAB    | `goog_...` (Google Play)    |
///
/// Keduanya punya nilai bawaan di kode, jadi `flutter run` dan
/// `flutter build appbundle --release` sama-sama berfungsi tanpa argumen
/// tambahan. Nilai bawaan itu aman karena key SDK RevenueCat memang publik.
///
/// Nilai non-publik — misalnya [legalBaseUrl] — tetap diisi lewat dart-define:
///
/// ```
/// cp dart_defines.example.json dart_defines.json   # lalu isi nilainya
/// flutter run --dart-define-from-file=dart_defines.json
/// ```
abstract final class MonetizationConfig {
  /// Nama entitlement di dashboard RevenueCat yang membuka fitur premium.
  static const entitlementId = 'pro';

  /// Key publik RevenueCat untuk Google Play.
  ///
  /// Punya nilai bawaan yang sengaja ditanam di kode. Alasannya dua. Pertama,
  /// key SDK RevenueCat memang **publik** — ia dirancang untuk ikut ke dalam
  /// binary app dan hanya mengizinkan operasi sisi klien, berbeda dari secret
  /// key yang tidak boleh keluar dari server. Kedua, tanpa nilai bawaan,
  /// `flutter build appbundle --release` yang dijalankan tanpa
  /// `--dart-define-from-file` akan menghasilkan app tanpa key sama sekali:
  /// paywall kosong, tidak ada yang bisa dibeli, dan tidak ada tanda apa pun
  /// sampai seseorang membukanya di perangkat.
  ///
  /// Masih bisa ditimpa lewat dart-define bila kamu berpindah project.
  static const androidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_KEY',
    defaultValue: 'goog_yhYUxqEwsyIluACOTgGRLkTALuo',
  );

  static const iosApiKey = String.fromEnvironment('REVENUECAT_IOS_KEY');

  /// Key Test Store RevenueCat (berawalan `test_`).
  ///
  /// Test Store adalah backend penagihan tiruan: pembelian tidak menagih uang,
  /// tapi tetap memperbarui entitlement. Berguna untuk mengembangkan paywall
  /// sebelum produk di Play Console siap.
  ///
  /// Juga bernilai bawaan supaya `flutter run` tanpa dart-define langsung bisa
  /// menguji paywall. Key ini **tidak pernah** dipakai pada build rilis; lihat
  /// [resolveApiKey].
  static const testStoreKey = String.fromEnvironment(
    'REVENUECAT_TEST_KEY',
    defaultValue: 'test_xkhiIpvpIVdZOIOXkSICTzOxDrP',
  );

  /// Basis URL halaman legal yang dihosting statis (mis. GitHub Pages).
  static const legalBaseUrl = String.fromEnvironment(
    'LEGAL_BASE_URL',
    defaultValue: 'https://example.invalid/dilsensei',
  );

  /// Tautan wajib pada paywall langganan.
  static String get privacyPolicyUrl => '$legalBaseUrl/privacy.html';
  static String get termsUrl => '$legalBaseUrl/terms.html';

  static bool get hasAndroidKey => androidApiKey.isNotEmpty;
  static bool get hasIosKey => iosApiKey.isNotEmpty;

  /// True bila [key] adalah key Test Store, bukan key store sungguhan.
  static bool isTestKey(String key) => key.startsWith('test_');

  /// True bila key Test Store diisi saat build, terlepas dari mode build.
  ///
  /// Dipakai untuk mendeteksi kesalahan konfigurasi rilis, bukan untuk memilih
  /// service.
  static bool get isTestKeyProvided => testStoreKey.isNotEmpty;

  /// True bila key Test Store diisi tapi build-nya rilis — kombinasi yang
  /// hampir selalu merupakan kecelakaan.
  static bool get isTestKeyLeakingToRelease =>
      kReleaseMode && isTestKeyProvided;

  /// Key yang aktif dipakai: Test Store didahulukan bila diisi, karena itu
  /// berarti developer sedang sengaja menguji tanpa store.
  ///
  /// Pada build **rilis** key Test Store diabaikan sepenuhnya. Aturan Shipaton
  /// menuntut app terbit yang bisa benar-benar dibeli juri, dan pendapatan
  /// dihitung dari RevenueCat — Test Store tidak menghasilkan keduanya. Kalau
  /// key produksi belum ada, paywall lebih baik gagal terbuka secara terlihat
  /// daripada terbit dengan pembelian tiruan yang tampak berhasil.
  static String resolveApiKey({required String platformKey}) {
    if (kReleaseMode) return platformKey;

    return testStoreKey.isNotEmpty ? testStoreKey : platformKey;
  }

  /// True bila app sedang berjalan di atas Test Store.
  ///
  /// Dipakai untuk menandai paywall secara mencolok, supaya pembelian tiruan
  /// tidak pernah disalahartikan sebagai pembelian nyata.
  static bool get isUsingTestStore => !kReleaseMode && isTestKeyProvided;

  /// False bila LEGAL_BASE_URL belum diisi saat build.
  static bool get hasValidLegalUrls {
    final uri = Uri.tryParse(legalBaseUrl);

    return uri != null &&
        uri.isScheme('https') &&
        uri.host.isNotEmpty &&
        !uri.host.endsWith('.invalid') &&
        !legalBaseUrl.endsWith('/');
  }
}
