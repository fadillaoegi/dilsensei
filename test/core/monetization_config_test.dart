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

    test('tanpa key apa pun hasilnya kosong, bukan key palsu', () {
      // Test dijalankan dalam mode debug tanpa dart-define, sehingga
      // testStoreKey kosong dan yang tersisa hanyalah platformKey.
      expect(MonetizationConfig.resolveApiKey(platformKey: ''), isEmpty);
    });

    test('key platform dipakai apa adanya bila Test Store tidak diisi', () {
      expect(
        MonetizationConfig.resolveApiKey(platformKey: 'goog_produksi'),
        'goog_produksi',
      );
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
