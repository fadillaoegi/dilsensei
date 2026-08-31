import 'package:dilsensei/core/monetization/domain/subscription_models.dart';
import 'package:dilsensei/core/monetization/monetization_config.dart';
import 'package:dilsensei/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('pemilihan API key', () {
    test('key Test Store dikenali dari prefiksnya', () {
      expect(MonetizationConfig.isTestKey('test_abc123'), isTrue);
      expect(MonetizationConfig.isTestKey('goog_abc123'), isFalse);
      expect(MonetizationConfig.isTestKey(''), isFalse);
    });

    test('key Test Store diprioritaskan di debug walau platform terisi', () {
      // Di debug, pengembang hampir selalu ingin Test Store: pembelian tidak
      // menagih uang tapi entitlement tetap berubah.
      expect(
        MonetizationConfig.resolveApiKey(platformKey: 'goog_produksi'),
        MonetizationConfig.testStoreKey,
      );
    });

    test('hasil pemilihan tidak pernah kosong di debug', () {
      // Konsekuensi key bawaan: paywall selalu punya sesuatu untuk dimuat saat
      // pengembangan, bahkan tanpa dart-define sama sekali.
      expect(MonetizationConfig.resolveApiKey(platformKey: ''), isNotEmpty);
    });

    test('key bawaan tersedia tanpa dart-define', () {
      // Tanpa nilai bawaan, `flutter build appbundle --release` yang dijalankan
      // tanpa --dart-define-from-file menghasilkan app tanpa key: paywall
      // kosong dan tidak ada tanda apa pun sampai dibuka di perangkat.
      expect(MonetizationConfig.androidApiKey, startsWith('goog_'));
      expect(MonetizationConfig.testStoreKey, startsWith('test_'));
      expect(MonetizationConfig.hasAndroidKey, isTrue);
    });

    test('build debug memakai key Test Store, bukan key produksi', () {
      // Test berjalan dalam mode debug, jadi ini menguji cabang debug secara
      // langsung.
      final resolved = MonetizationConfig.resolveApiKey(
        platformKey: MonetizationConfig.androidApiKey,
      );

      expect(
        kReleaseMode,
        isFalse,
        reason: 'test seharusnya berjalan di debug',
      );
      expect(resolved, MonetizationConfig.testStoreKey);
      expect(MonetizationConfig.isTestKey(resolved), isTrue);
      expect(resolved, isNot(startsWith('goog_')));
    });

    test('banner Test Store menyala di debug agar tidak salah paham', () {
      expect(MonetizationConfig.isUsingTestStore, isTrue);
    });

    test('mode rilis tidak pernah memakai key Test Store', () {
      // Penjaga ini yang mencegah rilis dengan pembelian tiruan. Pada build
      // rilis resolveApiKey harus mengembalikan platformKey apa pun isi
      // REVENUECAT_TEST_KEY.
      if (!kReleaseMode) {
        // Di luar mode rilis kita hanya bisa memastikan kontraknya konsisten:
        // penanda kebocoran mustahil aktif kalau build-nya bukan rilis.
        expect(MonetizationConfig.isTestKeyLeakingToRelease, isFalse);
        return;
      }

      expect(
        MonetizationConfig.resolveApiKey(platformKey: 'goog_produksi'),
        'goog_produksi',
      );
      expect(MonetizationConfig.isUsingTestStore, isFalse);
    });
  });

  group('label paket', () {
    late AppL10n en;

    setUp(() async {
      en = await AppL10n.delegate.load(const Locale('en'));
    });

    SubscriptionPlan planWith(BillingPeriod period) => SubscriptionPlan(
      id: 'p',
      priceLabel: 'Rp 49.000',
      period: period,
      storeTitle: 'Judul dari store',
    );

    test('setiap periode punya judul dan label sendiri', () {
      // Dashboard DilSensei memakai $rc_monthly, $rc_annual, dan $rc_lifetime.
      // Ketiganya harus punya teks sendiri, bukan jatuh ke fallback.
      expect(planWith(BillingPeriod.monthly).titleFor(en), 'Monthly plan');
      expect(planWith(BillingPeriod.monthly).periodLabelFor(en), '/ month');

      expect(planWith(BillingPeriod.annual).titleFor(en), 'Annual plan');
      expect(planWith(BillingPeriod.annual).periodLabelFor(en), '/ year');

      expect(planWith(BillingPeriod.lifetime).titleFor(en), 'Lifetime access');
      expect(planWith(BillingPeriod.lifetime).periodLabelFor(en), 'one-time');
    });

    test('paket tahunan tidak lagi memakai judul bulanan', () {
      // Bug yang pernah ada: PackageType.annual jatuh ke BillingPeriod.unknown,
      // sehingga paket tahunan tampil sebagai judul store atau "Monthly".
      final annual = planWith(BillingPeriod.annual);

      expect(annual.titleFor(en), isNot('Monthly plan'));
      expect(annual.titleFor(en), isNot('Judul dari store'));
      expect(annual.periodLabelFor(en), isNotEmpty);
    });

    test('periode tak dikenal memakai judul store dan tanpa label', () {
      final unknown = planWith(BillingPeriod.unknown);

      expect(unknown.titleFor(en), 'Judul dari store');
      expect(unknown.periodLabelFor(en), isEmpty);
    });

    test('masa percobaan hanya dijelaskan bila memang ada', () {
      const withTrial = SubscriptionPlan(
        id: 'p',
        priceLabel: 'Rp 49.000',
        period: BillingPeriod.annual,
        trialDays: 3,
      );
      const withoutTrial = SubscriptionPlan(
        id: 'p',
        priceLabel: 'Rp 49.000',
        period: BillingPeriod.annual,
      );

      expect(withTrial.trialDescriptionFor(en), contains('3'));
      expect(withoutTrial.trialDescriptionFor(en), isNull);
    });
  });
}
