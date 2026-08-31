import 'package:dilsensei/core/monetization/data/revenuecat_subscription_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('inisialisasi RevenueCat', () {
    test('SDK hanya dikonfigurasi sekali walau dipanggil berulang', () async {
      var configureCount = 0;

      final service = RevenueCatSubscriptionService(
        apiKey: 'test_kunci',
        configure: (_) async => configureCount++,
      );

      await service.initialize();
      await service.initialize();
      await service.initialize();

      expect(configureCount, 1);
    });

    test('dua pemanggil bersamaan tidak mengonfigurasi SDK dua kali', () async {
      // Ini bug yang pernah ada. Bendera bool baru menjadi true setelah await,
      // sehingga status premium dan daftar paket yang sama-sama memanggil
      // initialize saat app dibuka lolos penjaga bersamaan.
      var configureCount = 0;

      final service = RevenueCatSubscriptionService(
        apiKey: 'test_kunci',
        configure: (_) async {
          // Menirukan panggilan platform yang tidak selesai seketika.
          await Future<void>.delayed(const Duration(milliseconds: 20));
          configureCount++;
        },
      );

      await Future.wait<void>([
        service.initialize(),
        service.initialize(),
        service.initialize(),
      ]);

      expect(
        configureCount,
        1,
        reason: 'configure terpanggil $configureCount kali, seharusnya sekali',
      );
    });

    test('key yang diberikan diteruskan ke SDK apa adanya', () async {
      String? received;

      final service = RevenueCatSubscriptionService(
        apiKey: 'goog_kunci_produksi',
        configure: (apiKey) async => received = apiKey,
      );

      await service.initialize();

      expect(received, 'goog_kunci_produksi');
    });
  });
}
