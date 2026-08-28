import 'subscription_models.dart';

/// Kontrak monetisasi yang dipakai layer presentation.
///
/// Implementasi nyatanya memakai RevenueCat, tapi UI dan test hanya bergantung
/// pada kontrak ini.
abstract interface class SubscriptionService {
  /// Menyiapkan SDK. Aman dipanggil lebih dari sekali.
  Future<void> initialize();

  /// Status premium yang berubah seiring pembelian, restore, atau kedaluwarsa.
  Stream<PremiumStatus> premiumStatusChanges();

  /// Status premium terkini.
  Future<PremiumStatus> currentStatus();

  /// Paket yang tersedia untuk ditampilkan di paywall.
  Future<List<SubscriptionPlan>> fetchPlans();

  Future<PurchaseResult> purchase(String planId);

  /// Wajib ada di paywall sesuai aturan store.
  Future<PurchaseResult> restorePurchases();
}
