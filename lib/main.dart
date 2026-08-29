import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/analytics/analytics_providers.dart';
import 'core/localization/language_controller.dart';
import 'core/monetization/monetization_config.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _warnOnMissingConfig();

  // Firebase disiapkan sebelum runApp supaya analytics siap sejak layar pertama.
  // Kegagalannya tidak menghalangi app berjalan.
  await initializeFirebase();

  runApp(const ProviderScope(child: DilSenseiApp()));
}

/// Peringatan saat debug agar konfigurasi yang belum diisi tidak lolos diam-diam
/// sampai proses review store.
void _warnOnMissingConfig() {
  // Rilis yang masih membawa key Test Store hampir pasti kecelakaan: juri tidak
  // akan bisa membeli dan pendapatannya tidak tercatat di RevenueCat.
  if (MonetizationConfig.isTestKeyLeakingToRelease) {
    debugPrint(
      'MONETISASI: build rilis ini menyertakan REVENUECAT_TEST_KEY. '
      'Key tersebut diabaikan. Isi REVENUECAT_ANDROID_KEY (goog_...) '
      'sebelum mengunggah ke Play.',
    );
  }

  if (!kDebugMode) return;

  if (!MonetizationConfig.hasAndroidKey) {
    debugPrint(
      'KONFIGURASI: REVENUECAT_ANDROID_KEY belum diisi. '
      'Pembelian tidak akan berfungsi. '
      'Jalankan dengan --dart-define=REVENUECAT_ANDROID_KEY=goog_xxx',
    );
  }

  if (!MonetizationConfig.hasValidLegalUrls) {
    debugPrint(
      'KONFIGURASI: LEGAL_BASE_URL belum diisi, tautan Privacy Policy dan '
      'Terms pada paywall akan rusak dan Play akan menolak app. '
      'Jalankan dengan --dart-define=LEGAL_BASE_URL=https://namamu.github.io/dilsensei',
    );
  }
}

class DilSenseiApp extends ConsumerWidget {
  const DilSenseiApp({this.router, super.key});

  /// Dapat di-inject supaya setiap test memakai instance router yang bersih.
  final GoRouter? router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'DilSensei',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      routerConfig: router ?? appRouter,
    );
  }
}
