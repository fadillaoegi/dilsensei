/// Periode tagihan sebuah paket.
enum BillingPeriod { weekly, monthly, lifetime, unknown }

/// Paket langganan yang siap ditampilkan di paywall.
///
/// Sengaja tidak menyimpan tipe milik SDK RevenueCat supaya layer presentation
/// dan test tidak bergantung pada plugin native.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.period,
    this.trialDescription,
    this.isRecommended = false,
  });

  final String id;
  final String title;

  /// Harga sudah terformat sesuai mata uang perangkat, misalnya "Rp 49.000".
  final String priceLabel;
  final BillingPeriod period;

  /// Deskripsi masa percobaan bila tersedia, misalnya "3 hari gratis".
  final String? trialDescription;
  final bool isRecommended;

  String get periodLabel => switch (period) {
    BillingPeriod.weekly => '/ minggu',
    BillingPeriod.monthly => '/ bulan',
    BillingPeriod.lifetime => 'sekali bayar',
    BillingPeriod.unknown => '',
  };
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

class PurchaseResult {
  const PurchaseResult({required this.outcome, this.message});

  const PurchaseResult.success()
    : outcome = PurchaseOutcome.success,
      message = null;

  const PurchaseResult.cancelled()
    : outcome = PurchaseOutcome.cancelled,
      message = null;

  const PurchaseResult.failed(this.message) : outcome = PurchaseOutcome.failed;

  final PurchaseOutcome outcome;
  final String? message;

  bool get isSuccess => outcome == PurchaseOutcome.success;
}
