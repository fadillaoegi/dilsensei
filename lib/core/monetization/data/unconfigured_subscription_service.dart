import 'dart:async';

import '../domain/subscription_models.dart';
import '../domain/subscription_service.dart';

/// Service pengganti saat API key RevenueCat belum tersedia.
///
/// Dipakai agar app tetap bisa dijalankan dan diuji sebelum produk langganan di
/// Play Console siap. Pembelian di sini **tidak pernah** memberi akses premium,
/// supaya tidak ada jalur palsu yang lolos ke rilis produksi.
class UnconfiguredSubscriptionService implements SubscriptionService {
  UnconfiguredSubscriptionService();

  final StreamController<PremiumStatus> _controller =
      StreamController<PremiumStatus>.broadcast();

  @override
  Future<void> initialize() async {}

  @override
  Stream<PremiumStatus> premiumStatusChanges() => _controller.stream;

  @override
  Future<PremiumStatus> currentStatus() async => const PremiumStatus.free();

  @override
  Future<List<SubscriptionPlan>> fetchPlans() async =>
      const <SubscriptionPlan>[];

  @override
  Future<PurchaseResult> purchase(String planId) async {
    return const PurchaseResult.failed(
      'Pembelian belum tersedia. Konfigurasi RevenueCat belum dipasang.',
    );
  }

  @override
  Future<PurchaseResult> restorePurchases() async {
    return const PurchaseResult.failed(
      'Restore belum tersedia. Konfigurasi RevenueCat belum dipasang.',
    );
  }
}
