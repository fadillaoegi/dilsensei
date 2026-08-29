import '../../../l10n/app_localizations.dart';

/// Periode tagihan sebuah paket.
enum BillingPeriod { weekly, monthly, annual, lifetime, unknown }

/// Paket langganan yang siap ditampilkan di paywall.
///
/// Sengaja tidak menyimpan tipe milik SDK RevenueCat supaya layer presentation
/// dan test tidak bergantung pada plugin native.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.priceLabel,
    required this.period,
    this.storeTitle,
    this.trialDays,
    this.isRecommended = false,
  });

  final String id;

  /// Judul dari store, dipakai hanya bila periodenya tidak dikenali.
  final String? storeTitle;

  /// Lama masa percobaan dalam hari, bila ada.
  final int? trialDays;

  /// Harga sudah terformat sesuai mata uang perangkat, misalnya "Rp 49.000".
  final String priceLabel;
  final BillingPeriod period;

  final bool isRecommended;

  /// Judul paket sesuai bahasa aktif.
  String titleFor(AppL10n l10n) => switch (period) {
    BillingPeriod.weekly => l10n.planTitleWeekly,
    BillingPeriod.monthly => l10n.planTitleMonthly,
    BillingPeriod.annual => l10n.planTitleAnnual,
    BillingPeriod.lifetime => l10n.planTitleLifetime,
    BillingPeriod.unknown => storeTitle ?? l10n.planTitleMonthly,
  };

  String periodLabelFor(AppL10n l10n) => switch (period) {
    BillingPeriod.weekly => l10n.planPeriodWeekly,
    BillingPeriod.monthly => l10n.planPeriodMonthly,
    BillingPeriod.annual => l10n.planPeriodAnnual,
    BillingPeriod.lifetime => l10n.planPeriodLifetime,
    BillingPeriod.unknown => '',
  };

  /// Deskripsi masa percobaan sesuai bahasa aktif, misalnya "3 days free".
  String? trialDescriptionFor(AppL10n l10n) {
    final days = trialDays;
    if (days == null || days <= 0) return null;

    return l10n.planTrialFree(days, l10n.planUnitDay);
  }
}

/// Status premium pengguna saat ini.
class PremiumStatus {
  const PremiumStatus({required this.isPremium, this.expiresAt});

  const PremiumStatus.free() : isPremium = false, expiresAt = null;

  final bool isPremium;
  final DateTime? expiresAt;
}

/// Hasil upaya pembelian.
enum PurchaseOutcome { success, cancelled, failed }

/// Sebab kegagalan, supaya pesannya bisa dilokalisasi di layer presentation.
///
/// Service tidak boleh memutuskan kalimat yang dibaca pengguna: ia hanya
/// melaporkan sebabnya, dan UI memilih teks sesuai bahasa aktif.
enum PurchaseFailure {
  none,
  planNotFound,
  notActive,
  noneToRestore,
  storeError,
  notConfigured,
  unknown,
}

class PurchaseResult {
  const PurchaseResult({
    required this.outcome,
    this.failure = PurchaseFailure.none,
    this.message,
  });

  const PurchaseResult.success()
    : outcome = PurchaseOutcome.success,
      failure = PurchaseFailure.none,
      message = null;

  const PurchaseResult.cancelled()
    : outcome = PurchaseOutcome.cancelled,
      failure = PurchaseFailure.none,
      message = null;

  const PurchaseResult.failed(
    this.message, {
    this.failure = PurchaseFailure.unknown,
  }) : outcome = PurchaseOutcome.failed;

  final PurchaseOutcome outcome;
  final PurchaseFailure failure;

  /// Keterangan tambahan dari store, bila ada. Bukan teks siap tampil.
  final String? message;

  bool get isSuccess => outcome == PurchaseOutcome.success;
}
