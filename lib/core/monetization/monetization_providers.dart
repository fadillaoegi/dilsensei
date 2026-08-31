import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../diagnostics/diagnostics_log.dart';
import '../diagnostics/diagnostics_providers.dart';
import 'data/revenuecat_subscription_service.dart';
import 'data/unconfigured_subscription_service.dart';
import 'dev_premium_override.dart';
import 'domain/subscription_models.dart';
import 'domain/subscription_service.dart';
import 'monetization_config.dart';

/// Memilih implementasi langganan sesuai ketersediaan API key.
///
/// Urutannya: key Test Store bila diisi, lalu key store sesuai platform.
/// Selama keduanya kosong, app memakai fallback yang tidak pernah memberi akses
/// premium — jadi tidak ada jalur palsu ke produksi.
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final log = ref.watch(diagnosticsLogProvider);
  final platformKey = _platformKey() ?? '';
  final apiKey = MonetizationConfig.resolveApiKey(platformKey: platformKey);

  // Keputusan pemilihan key dicatat lebih dulu, karena inilah penyebab
  // tersering paywall kosong: build rilis mengabaikan key Test Store, dan bila
  // key produksi belum diisi maka tidak ada key sama sekali.
  log.record(
    'monetisasi',
    'memilih key langganan',
    level: apiKey.isEmpty ? DiagnosticSeverity.error : DiagnosticSeverity.info,
    detail:
        'dipakai=${maskKey(apiKey)} '
        'keyPlatform=${maskKey(platformKey)} '
        'testStoreDiisi=${MonetizationConfig.isTestKeyProvided} '
        'modeRilis=$kReleaseMode',
  );

  if (apiKey.isEmpty) {
    log.record(
      'monetisasi',
      'tidak ada API key: pembelian tidak mungkin dijalankan',
      level: DiagnosticSeverity.error,
      detail: 'isi REVENUECAT_ANDROID_KEY (goog_...) saat build rilis',
    );

    return UnconfiguredSubscriptionService();
  }

  return RevenueCatSubscriptionService(apiKey: apiKey, diagnostics: log);
});

String? _platformKey() {
  if (kIsWeb) return null;

  if (Platform.isAndroid) return MonetizationConfig.androidApiKey;
  if (Platform.isIOS || Platform.isMacOS) return MonetizationConfig.iosApiKey;

  return null;
}

/// Status premium: nilai awal dari store, lalu diperbarui oleh listener SDK.
final premiumStatusProvider = StreamProvider<PremiumStatus>((ref) async* {
  final service = ref.watch(subscriptionServiceProvider);
  await service.initialize();

  yield await service.currentStatus();
  yield* service.premiumStatusChanges();
});

/// Penjaga akses konten premium; default aman ke non-premium saat masih memuat.
///
/// Pada build debug/profile, override dev dapat memaksa nilai ini true. Pada
/// build release override tersebut selalu tidak aktif.
final isPremiumProvider = Provider<bool>((ref) {
  if (ref.watch(isDevPremiumActiveProvider)) return true;

  return ref.watch(premiumStatusProvider).valueOrNull?.isPremium ?? false;
});

/// Paket yang ditampilkan di paywall.
final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlan>>((
  ref,
) async {
  final service = ref.watch(subscriptionServiceProvider);
  await service.initialize();

  return service.fetchPlans();
});
