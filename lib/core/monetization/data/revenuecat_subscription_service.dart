import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
// PurchaseResult milik SDK disembunyikan agar tidak bertabrakan dengan
// PurchaseResult milik domain kita.
import 'package:purchases_flutter/purchases_flutter.dart' hide PurchaseResult;

import '../domain/subscription_models.dart';
import '../domain/subscription_service.dart';
import '../monetization_config.dart';

/// Implementasi langganan di atas SDK RevenueCat.
///
/// Seluruh tipe milik SDK berhenti di kelas ini; layer lain hanya melihat
/// [SubscriptionPlan] dan [PremiumStatus].
class RevenueCatSubscriptionService implements SubscriptionService {
  RevenueCatSubscriptionService({required this.apiKey});

  final String apiKey;

  final StreamController<PremiumStatus> _statusController =
      StreamController<PremiumStatus>.broadcast();

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
    await Purchases.configure(PurchasesConfiguration(apiKey));

    Purchases.addCustomerInfoUpdateListener((info) {
      _statusController.add(_statusFrom(info));
    });

    _isInitialized = true;
  }

  @override
  Stream<PremiumStatus> premiumStatusChanges() => _statusController.stream;

  @override
  Future<PremiumStatus> currentStatus() async {
    try {
      return _statusFrom(await Purchases.getCustomerInfo());
    } on PlatformException {
      // Gagal menghubungi store tidak boleh membuat app berhenti; anggap gratis.
      return const PremiumStatus.free();
    }
  }

  @override
  Future<List<SubscriptionPlan>> fetchPlans() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return const <SubscriptionPlan>[];

      final packages = current.availablePackages;

      return packages
          .map(
            (package) => _planFrom(
              package,
              isRecommended: packages.length > 1 && package == packages.first,
            ),
          )
          .toList(growable: false);
    } on PlatformException {
      return const <SubscriptionPlan>[];
    }
  }

  @override
  Future<PurchaseResult> purchase(String planId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final package = offerings.current?.availablePackages
          .where((item) => item.identifier == planId)
          .firstOrNull;

      if (package == null) {
        return const PurchaseResult.failed('Paket tidak ditemukan.');
      }

      final result = await Purchases.purchase(PurchaseParams.package(package));
      final status = _statusFrom(result.customerInfo);
      _statusController.add(status);

      return status.isPremium
          ? const PurchaseResult.success()
          : const PurchaseResult.failed('Langganan belum aktif.');
    } on PlatformException catch (error) {
      if (PurchasesErrorHelper.getErrorCode(error) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return const PurchaseResult.cancelled();
      }
      return PurchaseResult.failed(error.message ?? 'Pembelian gagal.');
    }
  }

  @override
  Future<PurchaseResult> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      final status = _statusFrom(info);
      _statusController.add(status);

      return status.isPremium
          ? const PurchaseResult.success()
          : const PurchaseResult.failed(
              'Tidak ada langganan aktif untuk akun ini.',
            );
    } on PlatformException catch (error) {
      return PurchaseResult.failed(error.message ?? 'Restore gagal.');
    }
  }

  PremiumStatus _statusFrom(CustomerInfo info) {
    final entitlement = info.entitlements.all[MonetizationConfig.entitlementId];
    final isActive = entitlement?.isActive ?? false;
    final expiration = entitlement?.expirationDate;

    return PremiumStatus(
      isPremium: isActive,
      expiresAt: expiration == null ? null : DateTime.tryParse(expiration),
    );
  }

  SubscriptionPlan _planFrom(Package package, {required bool isRecommended}) {
    final product = package.storeProduct;

    return SubscriptionPlan(
      id: package.identifier,
      title: _titleFor(package.packageType, product.title),
      priceLabel: product.priceString,
      period: _periodFor(package.packageType),
      trialDescription: _trialFor(product),
      isRecommended: isRecommended,
    );
  }

  String _titleFor(PackageType type, String fallback) => switch (type) {
    PackageType.weekly => 'Paket Mingguan',
    PackageType.monthly => 'Paket Bulanan',
    PackageType.annual => 'Paket Tahunan',
    PackageType.lifetime => 'Akses Selamanya',
    _ => fallback,
  };

  BillingPeriod _periodFor(PackageType type) => switch (type) {
    PackageType.weekly => BillingPeriod.weekly,
    PackageType.monthly => BillingPeriod.monthly,
    PackageType.lifetime => BillingPeriod.lifetime,
    _ => BillingPeriod.unknown,
  };

  String? _trialFor(StoreProduct product) {
    final phase = product.defaultOption?.freePhase;
    final period = phase?.billingPeriod;
    if (period == null) return null;

    final unit = switch (period.unit) {
      PeriodUnit.day => 'hari',
      PeriodUnit.week => 'minggu',
      PeriodUnit.month => 'bulan',
      PeriodUnit.year => 'tahun',
      PeriodUnit.unknown => null,
    };
    if (unit == null) return null;

    return '${period.value} $unit gratis';
  }
}
