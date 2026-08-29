import '../../l10n/app_localizations.dart';
import 'domain/subscription_models.dart';

/// Menerjemahkan sebab kegagalan menjadi kalimat yang dibaca pengguna.
///
/// Dipisah dari service supaya service tetap bebas dari bahasa, dan dipakai
/// bersama oleh paywall maupun layar Pengaturan.
String purchaseFailureMessage(AppL10n l10n, PurchaseResult result) {
  return switch (result.failure) {
    PurchaseFailure.planNotFound => l10n.purchaseErrorPlanNotFound,
    PurchaseFailure.notActive => l10n.purchaseErrorNotActive,
    PurchaseFailure.noneToRestore => l10n.settingsRestoreEmpty,
    PurchaseFailure.storeError => l10n.purchaseErrorStore,
    PurchaseFailure.notConfigured => l10n.purchaseErrorNotConfigured,
    // Detail dari fake atau store dipakai apa adanya bila sebabnya tidak dikenal.
    PurchaseFailure.unknown => result.message ?? l10n.paywallPurchaseFailed,
    PurchaseFailure.none => l10n.paywallPurchaseFailed,
  };
}
