import 'package:dilsensei/core/monetization/domain/subscription_models.dart';
import 'package:dilsensei/features/monetization/presentation/screens/paywall_screen.dart';
import 'package:dilsensei/features/monetization/presentation/widgets/pricing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/lesson_test_fixtures.dart';

/// Membuka paywall lewat alur nyata: tap modul premium di HomeScreen.
Future<void> _openPaywall(
  WidgetTester tester, {
  FakeSubscriptionService? service,
}) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(
    buildTestApp(subscriptionService: service ?? FakeSubscriptionService()),
  );
  await pumpUntilLoaded(tester);

  await tapModule(tester, 'Angka & Jam');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('menampilkan proposisi nilai, benefit, dan harga dari store', (
    tester,
  ) async {
    await _openPaywall(tester);

    expect(find.byType(PaywallScreen), findsOneWidget);
    expect(find.text('Buka\nPotensi\nPenuhmu'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(4));

    // Harga berasal dari service, bukan hardcoded di UI.
    expect(find.text('Rp 49.000'), findsOneWidget);
    expect(find.text('/ bulan'), findsOneWidget);
    expect(find.text('Rp 249.000'), findsOneWidget);
    expect(find.text('3 hari gratis'), findsOneWidget);
    expect(find.text('HEMAT'), findsOneWidget);
    expect(find.byType(PricingCard), findsNWidgets(2));
  });

  testWidgets('paywall menyediakan Restore Purchases dan tautan legal', (
    tester,
  ) async {
    await _openPaywall(tester);

    expect(find.text('Restore Purchases'), findsOneWidget);
    expect(find.text('Terms of Use'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.textContaining('diperpanjang otomatis'), findsOneWidget);
  });

  testWidgets('paket rekomendasi terpilih otomatis dan bisa diganti', (
    tester,
  ) async {
    final service = FakeSubscriptionService();
    await _openPaywall(tester, service: service);

    final monthly = tester.widget<PricingCard>(
      find.widgetWithText(PricingCard, 'Paket Bulanan'),
    );
    expect(monthly.isSelected, isTrue, reason: 'rekomendasi terpilih default');

    // Kartu kedua berada di bawah lipatan pada viewport test.
    await tester.ensureVisible(find.text('Akses Selamanya'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Akses Selamanya'));
    await tester.pumpAndSettle();

    final lifetime = tester.widget<PricingCard>(
      find.widgetWithText(PricingCard, 'Akses Selamanya'),
    );
    expect(lifetime.isSelected, isTrue);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Mulai Langganan'));
    await tester.pumpAndSettle();

    expect(service.lastPurchasedPlanId, 'lifetime');
  });

  testWidgets('pembelian berhasil menutup paywall', (tester) async {
    final service = FakeSubscriptionService();
    await _openPaywall(tester, service: service);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Mulai Langganan'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(service.lastPurchasedPlanId, 'monthly');
    expect(find.text('Langganan aktif. Selamat berlatih!'), findsOneWidget);
    expect(find.byType(PaywallScreen), findsNothing);
  });

  testWidgets('pembelian dibatalkan tidak menampilkan pesan error', (
    tester,
  ) async {
    await _openPaywall(
      tester,
      service: FakeSubscriptionService(
        purchaseResult: const PurchaseResult.cancelled(),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Mulai Langganan'));
    await tester.pumpAndSettle();

    expect(find.byType(PaywallScreen), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('pembelian gagal menampilkan pesan dari service', (tester) async {
    await _openPaywall(
      tester,
      service: FakeSubscriptionService(
        purchaseResult: const PurchaseResult.failed('Kartu ditolak.'),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Mulai Langganan'));
    await tester.pumpAndSettle();

    expect(find.text('Kartu ditolak.'), findsOneWidget);
    expect(find.byType(PaywallScreen), findsOneWidget);
  });

  testWidgets('restore berhasil memulihkan dan menutup paywall', (
    tester,
  ) async {
    final service = FakeSubscriptionService();
    await _openPaywall(tester, service: service);

    await tester.tap(find.text('Restore Purchases'));
    await tester.pumpAndSettle();

    expect(service.restoreCallCount, 1);
    expect(find.text('Langganan berhasil dipulihkan.'), findsOneWidget);
    expect(find.byType(PaywallScreen), findsNothing);
  });

  testWidgets('restore tanpa langganan aktif memberi tahu pengguna', (
    tester,
  ) async {
    await _openPaywall(
      tester,
      service: FakeSubscriptionService(
        restoreResult: const PurchaseResult.failed(
          'Tidak ada langganan aktif untuk akun ini.',
        ),
      ),
    );

    await tester.tap(find.text('Restore Purchases'));
    await tester.pumpAndSettle();

    expect(
      find.text('Tidak ada langganan aktif untuk akun ini.'),
      findsOneWidget,
    );
    expect(find.byType(PaywallScreen), findsOneWidget);
  });

  testWidgets('gagal memuat paket menawarkan muat ulang', (tester) async {
    await _openPaywall(
      tester,
      service: FakeSubscriptionService(plansThrow: true),
    );

    expect(find.text('Harga belum bisa ditampilkan'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Muat Ulang'), findsOneWidget);

    final cta = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Mulai Langganan'),
    );
    expect(cta.onPressed, isNull, reason: 'tidak boleh membeli tanpa paket');
  });

  testWidgets('galat tak terduga saat membeli tidak mematikan tombol', (
    tester,
  ) async {
    // Ini bug yang benar-benar terjadi. Service melempar galat yang bukan
    // PlatformException — di web, SDK RevenueCat melempar
    // UnsupportedPlatformException — sehingga penanda "sedang diproses" tidak
    // pernah turun. Sejak itu tombol Mulai Langganan tampak disabled dan
    // Restore Purchases tidak bereaksi sama sekali, tanpa pesan apa pun.
    await _openPaywall(
      tester,
      service: FakeSubscriptionService(purchaseThrows: true),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Mulai Langganan'));
    await tester.pumpAndSettle();

    final cta = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Mulai Langganan'),
    );
    expect(cta.onPressed, isNotNull, reason: 'tombol harus hidup kembali');

    final restore = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Restore Purchases'),
    );
    expect(restore.onPressed, isNotNull);

    // Pengguna diberi tahu, bukan dibiarkan menebak.
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Store tidak bisa menyelesaikan pembelian.'),
      findsOneWidget,
    );
  });

  testWidgets('galat tak terduga saat restore tidak mematikan tombol', (
    tester,
  ) async {
    await _openPaywall(
      tester,
      service: FakeSubscriptionService(restoreThrows: true),
    );

    await tester.tap(find.text('Restore Purchases'));
    await tester.pumpAndSettle();

    final restore = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Restore Purchases'),
    );
    expect(restore.onPressed, isNotNull);

    final cta = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Mulai Langganan'),
    );
    expect(cta.onPressed, isNotNull);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
