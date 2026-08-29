import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/core/monetization/domain/subscription_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/lesson_test_fixtures.dart';

/// Frasa Indonesia yang tidak boleh pernah muncul saat app berbahasa Inggris.
///
/// Test lain memakai fixture berbahasa Indonesia, sehingga teks yang lupa
/// dilokalisasi tetap lolos di sana — persis bagaimana tombol onboarding
/// "Mulai Berlatih" bisa bertahan. Berkas ini penjaganya: setiap layar dibuka
/// dalam Bahasa Inggris, lalu jejak Bahasa Indonesia dinyatakan tidak boleh ada.
const _indonesianPhrases = <String>[
  'Lanjut',
  'Kembali',
  'Mulai Berlatih',
  'Selesai',
  'Periksa',
  'Hapus',
  'Ketuk potongan kata untuk menyusun jawaban',
  'Nama panggilan',
  'Pengaturan',
  'Versi gratis',
  'Peta Belajarmu',
  'Lihat paket Pro',
];

void _expectNoIndonesian() {
  for (final phrase in _indonesianPhrases) {
    expect(
      find.text(phrase),
      findsNothing,
      reason: '"$phrase" masih tampil padahal app berbahasa Inggris',
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('onboarding memakai teks Inggris di seluruh langkahnya', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(skipOnboarding: false, language: AppLanguage.english),
    );
    await pumpUntilLoaded(tester);

    // Langkah 1: nama.
    expect(find.text("Let's start with\nyour name"), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Continue'), findsOneWidget);
    _expectNoIndonesian();

    await tester.enterText(find.byType(TextField), 'Rina');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    // Langkah 2: tujuan belajar.
    expect(find.text('For work'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    _expectNoIndonesian();

    await tester.tap(find.text('For work'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    // Langkah 3: target harian, tombolnya berganti.
    expect(find.text('10 minutes · Steady'), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Start practising'),
      findsOneWidget,
      reason: 'tombol langkah terakhir juga harus terlokalisasi',
    );
    _expectNoIndonesian();
  });

  testWidgets('sesi latihan memakai teks Inggris termasuk petunjuk susun', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(buildTestApp(language: AppLanguage.english));
    await pumpUntilLoaded(tester);

    await tester.tap(find.text('Start session (5 min)'));
    await tester.pumpAndSettle();

    expect(
      find.text('Tap the word chips to build your answer'),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Check'), findsOneWidget);
    _expectNoIndonesian();
  });

  testWidgets('Pengaturan dan Home memakai teks Inggris', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(buildTestApp(language: AppLanguage.english));
    await pumpUntilLoaded(tester);
    await tester.pump();

    expect(find.text('Your roadmap'), findsOneWidget);
    _expectNoIndonesian();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Free plan'), findsOneWidget);
    _expectNoIndonesian();
  });

  testWidgets('pesan kegagalan pembelian ikut bahasa aktif', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildTestApp(
        language: AppLanguage.english,
        subscriptionService: FakeSubscriptionService(
          purchaseResult: const PurchaseResult.failed(
            null,
            failure: PurchaseFailure.storeError,
          ),
        ),
      ),
    );
    await pumpUntilLoaded(tester);

    await tapModule(tester, 'Angka & Jam');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Start subscription'));
    await tester.pumpAndSettle();

    expect(
      find.text('The store could not complete the purchase.'),
      findsOneWidget,
    );
    expect(
      find.text('Store tidak bisa menyelesaikan pembelian.'),
      findsNothing,
    );
  });
}
