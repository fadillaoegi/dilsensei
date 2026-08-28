/// Konfigurasi RevenueCat dan tautan legal.
///
/// Nilai sensitif maupun yang berbeda antar lingkungan diisi lewat dart-define
/// supaya tidak ikut masuk ke repository:
///
/// ```
/// flutter build appbundle \
///   --dart-define=REVENUECAT_ANDROID_KEY=goog_xxx \
///   --dart-define=LEGAL_BASE_URL=https://namamu.github.io/dilsensei
/// ```
abstract final class MonetizationConfig {
  /// Nama entitlement di dashboard RevenueCat yang membuka fitur premium.
  static const entitlementId = 'pro';

  static const androidApiKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
  static const iosApiKey = String.fromEnvironment('REVENUECAT_IOS_KEY');

  /// Basis URL halaman legal yang dihosting statis (mis. GitHub Pages).
  ///
  /// Default-nya sengaja placeholder yang mudah dideteksi, dan
  /// [hasValidLegalUrls] memastikan build rilis tidak lolos tanpa diisi.
  static const legalBaseUrl = String.fromEnvironment(
    'LEGAL_BASE_URL',
    defaultValue: 'https://example.invalid/dilsensei',
  );

  /// Tautan wajib pada paywall langganan.
  static String get privacyPolicyUrl => '$legalBaseUrl/privacy.html';
  static String get termsUrl => '$legalBaseUrl/terms.html';

  static bool get hasAndroidKey => androidApiKey.isNotEmpty;
  static bool get hasIosKey => iosApiKey.isNotEmpty;

  /// False bila LEGAL_BASE_URL belum diisi saat build.
  ///
  /// Play menolak app langganan tanpa tautan legal yang benar-benar hidup, jadi
  /// ini diperiksa sebelum rilis.
  static bool get hasValidLegalUrls {
    final uri = Uri.tryParse(legalBaseUrl);

    return uri != null &&
        uri.isScheme('https') &&
        uri.host.isNotEmpty &&
        !uri.host.endsWith('.invalid') &&
        !legalBaseUrl.endsWith('/');
  }
}
