import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
// PurchaseResult milik SDK disembunyikan agar tidak bertabrakan dengan
// PurchaseResult milik domain kita.
import 'package:purchases_flutter/purchases_flutter.dart' hide PurchaseResult;

import '../../diagnostics/diagnostics_log.dart';
import '../domain/subscription_models.dart';
import '../domain/subscription_service.dart';
import '../monetization_config.dart';

/// Implementasi langganan di atas SDK RevenueCat.
///
/// Seluruh tipe milik SDK berhenti di kelas ini; layer lain hanya melihat
/// [SubscriptionPlan] dan [PremiumStatus].
class RevenueCatSubscriptionService implements SubscriptionService {
  RevenueCatSubscriptionService({
    required this.apiKey,
    this.diagnostics,
    Future<void> Function(String apiKey)? configure,
  }) : _configure = configure ?? _configureSdk;

  final String apiKey;

  /// Log opsional. Bila diisi, setiap langkah dan setiap kode galat SDK dicatat
  /// sehingga penyebab kegagalan bisa dibaca dari dalam APK yang sudah dipasang.
  ///
  /// Publik karena lint proyek meminta initializing formal, dan parameter
  /// bernama tidak boleh diawali garis bawah.
  final DiagnosticsLog? diagnostics;

  /// Pemanggil `Purchases.configure`, dapat diganti oleh test untuk menghitung
  /// berapa kali SDK sebenarnya dikonfigurasi.
  final Future<void> Function(String apiKey) _configure;

  static Future<void> _configureSdk(String apiKey) async {
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  final StreamController<PremiumStatus> _statusController =
      StreamController<PremiumStatus>.broadcast();

  /// Future inisialisasi yang disimpan, bukan bendera bool.
  ///
  /// Bendera bool baru menjadi true setelah `await` selesai, sehingga dua
  /// pemanggil yang berjalan bersamaan — status premium dan daftar paket
  /// keduanya memanggil `initialize` saat app dibuka — sama-sama lolos penjaga
  /// dan mengonfigurasi SDK dua kali. Menyimpan Future-nya membuat pemanggil
  /// kedua menunggu hasil yang sama.
  Future<void>? _initialization;

  @override
  Future<void> initialize() => _initialization ??= _initializeOnce();

  void _log(
    String message, {
    DiagnosticSeverity level = DiagnosticSeverity.info,
    String? detail,
  }) {
    diagnostics?.record('revenuecat', message, level: level, detail: detail);
  }

  /// Menerjemahkan galat platform menjadi keterangan yang berguna.
  ///
  /// Kode galat RevenueCat adalah informasi paling menentukan saat pembelian
  /// gagal, dan sebelumnya hilang karena kita hanya memetakannya ke enum.
  String _describe(PlatformException error) {
    final code = PurchasesErrorHelper.getErrorCode(error);

    return 'kode=${code.name} platformCode=${error.code} '
        'pesan=${error.message ?? '-'}';
  }

  Future<void> _initializeOnce() async {
    _log('konfigurasi SDK dimulai', detail: 'key=${maskKey(apiKey)}');

    try {
      await _configure(apiKey);
    } on PlatformException catch (error) {
      _log(
        'konfigurasi SDK gagal',
        level: DiagnosticSeverity.error,
        detail: _describe(error),
      );
      rethrow;
    }

    Purchases.addCustomerInfoUpdateListener((info) {
      final status = _statusFrom(info);
      _log(
        'status pelanggan diperbarui',
        detail: 'premium=${status.isPremium}',
      );
      _statusController.add(status);
    });

    _log('konfigurasi SDK selesai');
  }

  @override
  Stream<PremiumStatus> premiumStatusChanges() => _statusController.stream;

  @override
  Future<PremiumStatus> currentStatus() async {
    try {
      // Setiap operasi menjamin konfigurasi sudah jalan. Tanpa ini, memanggil
      // operasi sebelum inisialisasi selesai membuat SDK melempar galat yang
      // sampai ke pengguna sebagai kegagalan store.
      await initialize();

      return _statusFrom(await Purchases.getCustomerInfo());
    } on PlatformException {
      // Gagal menghubungi store tidak boleh membuat app berhenti; anggap gratis.
      return const PremiumStatus.free();
    }
  }

  @override
  Future<List<SubscriptionPlan>> fetchPlans() async {
    try {
      await initialize();

      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        _log(
          'tidak ada offering yang ditandai Current',
          level: DiagnosticSeverity.error,
          detail: 'jumlahOffering=${offerings.all.length}',
        );

        return const <SubscriptionPlan>[];
      }

      final packages = current.availablePackages;
      _log(
        'offering dimuat',
        level: packages.isEmpty
            ? DiagnosticSeverity.error
            : DiagnosticSeverity.info,
        detail:
            'offering=${current.identifier} jumlahPaket=${packages.length} '
            'paket=${packages.map((p) => p.identifier).join(",")}',
      );

      return packages
          .map(
            (package) => _planFrom(
              package,
              isRecommended: packages.length > 1 && package == packages.first,
            ),
          )
          .toList(growable: false);
    } on PlatformException catch (error) {
      _log(
        'gagal memuat offering',
        level: DiagnosticSeverity.error,
        detail: _describe(error),
      );

      return const <SubscriptionPlan>[];
    }
  }

  @override
  Future<PurchaseResult> purchase(String planId) async {
    try {
      await initialize();

      final offerings = await Purchases.getOfferings();
      final package = offerings.current?.availablePackages
          .where((item) => item.identifier == planId)
          .firstOrNull;

      if (package == null) {
        _log(
          'paket tidak ditemukan di offering Current',
          level: DiagnosticSeverity.error,
          detail: 'diminta=$planId',
        );

        return const PurchaseResult.failed(
          null,
          failure: PurchaseFailure.planNotFound,
        );
      }

      _log('pembelian dimulai', detail: 'paket=$planId');

      final result = await Purchases.purchase(PurchaseParams.package(package));
      final status = _statusFrom(result.customerInfo);
      _statusController.add(status);

      if (status.isPremium) {
        _log('pembelian berhasil dan entitlement aktif');

        return const PurchaseResult.success();
      }

      // Gejala khas produk yang belum dilampirkan ke entitlement di dashboard:
      // pembayaran lolos tapi entitlement tidak pernah menyala.
      _log(
        'pembelian selesai tapi entitlement belum aktif',
        level: DiagnosticSeverity.error,
        detail:
            'entitlement=${MonetizationConfig.entitlementId} '
            'entitlementTerdaftar='
            '${result.customerInfo.entitlements.all.keys.join(",")}',
      );

      return const PurchaseResult.failed(
        null,
        failure: PurchaseFailure.notActive,
      );
    } on PlatformException catch (error) {
      if (PurchasesErrorHelper.getErrorCode(error) ==
          PurchasesErrorCode.purchaseCancelledError) {
        _log('pembelian dibatalkan pengguna');

        return const PurchaseResult.cancelled();
      }

      _log(
        'pembelian gagal',
        level: DiagnosticSeverity.error,
        detail: _describe(error),
      );

      return PurchaseResult.failed(
        error.message,
        failure: PurchaseFailure.storeError,
      );
    }
  }

  @override
  Future<PurchaseResult> restorePurchases() async {
    try {
      await initialize();

      final info = await Purchases.restorePurchases();
      final status = _statusFrom(info);
      _statusController.add(status);

      _log('restore selesai', detail: 'premium=${status.isPremium}');

      return status.isPremium
          ? const PurchaseResult.success()
          : const PurchaseResult.failed(
              null,
              failure: PurchaseFailure.noneToRestore,
            );
    } on PlatformException catch (error) {
      _log(
        'restore gagal',
        level: DiagnosticSeverity.error,
        detail: _describe(error),
      );

      return PurchaseResult.failed(
        error.message,
        failure: PurchaseFailure.storeError,
      );
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
      storeTitle: product.title,
      priceLabel: product.priceString,
      price: product.price,
      currencyCode: product.currencyCode,
      period: _periodFor(package.packageType),
      trialDays: _trialDaysFor(product),
      isRecommended: isRecommended,
    );
  }

  BillingPeriod _periodFor(PackageType type) => switch (type) {
    PackageType.weekly => BillingPeriod.weekly,
    PackageType.monthly => BillingPeriod.monthly,
    // Dashboard DilSensei memakai $rc_annual; tanpa baris ini paket tahunan
    // tampil sebagai "Bulanan" tanpa label periode.
    PackageType.annual => BillingPeriod.annual,
    PackageType.lifetime => BillingPeriod.lifetime,
    _ => BillingPeriod.unknown,
  };

  /// Lama masa percobaan dalam hari; null bila produk tidak menawarkannya.
  int? _trialDaysFor(StoreProduct product) {
    final period = product.defaultOption?.freePhase?.billingPeriod;
    if (period == null) return null;

    return switch (period.unit) {
      PeriodUnit.day => period.value,
      PeriodUnit.week => period.value * 7,
      PeriodUnit.month => period.value * 30,
      PeriodUnit.year => period.value * 365,
      PeriodUnit.unknown => null,
    };
  }
}
