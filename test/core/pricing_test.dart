import 'package:dilsensei/core/monetization/domain/subscription_models.dart';
import 'package:flutter_test/flutter_test.dart';

SubscriptionPlan planOf({
  required BillingPeriod period,
  required double price,
  String currency = 'USD',
  String? label,
}) {
  return SubscriptionPlan(
    id: period.name,
    priceLabel: label ?? '\$$price',
    price: price,
    currencyCode: currency,
    period: period,
  );
}

void main() {
  group('penghematan paket tahunan', () {
    test('menghitung diskon dari harga nyata di store', () {
      // Harga rencana: bulanan 2.99, tahunan 24.99.
      // Setahun bila bayar bulanan = 35.88, jadi hemat sekitar 30%.
      final percent = SubscriptionPlan.annualSavingsPercent(
        monthly: planOf(period: BillingPeriod.monthly, price: 2.99),
        annual: planOf(period: BillingPeriod.annual, price: 24.99),
      );

      expect(percent, 30);
    });

    test('angkanya ikut berubah bila harga di store berubah', () {
      // Ini alasan diskon tidak dipatok di kode: mengubah harga di Play Console
      // tidak boleh membuat badge-nya berbohong.
      final percent = SubscriptionPlan.annualSavingsPercent(
        monthly: planOf(period: BillingPeriod.monthly, price: 2.99),
        annual: planOf(period: BillingPeriod.annual, price: 17.94),
      );

      expect(percent, 50);
    });

    test('bekerja pada mata uang apa pun selama keduanya sama', () {
      // Rupiah, dengan rasio yang sama seperti versi dolar.
      final percent = SubscriptionPlan.annualSavingsPercent(
        monthly: planOf(
          period: BillingPeriod.monthly,
          price: 49000,
          currency: 'IDR',
        ),
        annual: planOf(
          period: BillingPeriod.annual,
          price: 411600,
          currency: 'IDR',
        ),
      );

      expect(percent, 30);
    });

    test('menolak menghitung bila mata uangnya berbeda', () {
      // Membandingkan dolar dengan rupiah akan menghasilkan diskon palsu.
      final percent = SubscriptionPlan.annualSavingsPercent(
        monthly: planOf(
          period: BillingPeriod.monthly,
          price: 2.99,
          currency: 'USD',
        ),
        annual: planOf(
          period: BillingPeriod.annual,
          price: 411600,
          currency: 'IDR',
        ),
      );

      expect(percent, isNull);
    });

    test('tidak ada badge bila tahunan justru tidak lebih murah', () {
      final percent = SubscriptionPlan.annualSavingsPercent(
        monthly: planOf(period: BillingPeriod.monthly, price: 2.99),
        annual: planOf(period: BillingPeriod.annual, price: 40),
      );

      expect(percent, isNull);
    });

    test('tidak ada badge bila store tidak melaporkan harga numerik', () {
      const monthly = SubscriptionPlan(
        id: 'monthly',
        priceLabel: 'Rp 49.000',
        period: BillingPeriod.monthly,
      );
      const annual = SubscriptionPlan(
        id: 'annual',
        priceLabel: 'Rp 411.600',
        period: BillingPeriod.annual,
      );

      expect(
        SubscriptionPlan.annualSavingsPercent(monthly: monthly, annual: annual),
        isNull,
      );
    });

    test('paket bulanan yang tidak ada tidak membuat perhitungan gagal', () {
      expect(
        SubscriptionPlan.annualSavingsPercent(
          monthly: null,
          annual: planOf(period: BillingPeriod.annual, price: 24.99),
        ),
        isNull,
      );
    });
  });

  group('label harga', () {
    test('label dipakai apa adanya dari store, tanpa konversi', () {
      // Aturan keras: app tidak pernah mengonversi mata uang. Yang ditampilkan
      // harus sama dengan yang benar-benar ditagih Google Play, dan Play
      // menentukannya dari negara penagihan pengguna — bukan dari bahasa app.
      const plan = SubscriptionPlan(
        id: 'monthly',
        priceLabel: 'Rp 49.000',
        price: 49000,
        currencyCode: 'IDR',
        period: BillingPeriod.monthly,
      );

      expect(plan.priceLabel, 'Rp 49.000');
      expect(plan.currencyCode, 'IDR');
    });
  });
}
