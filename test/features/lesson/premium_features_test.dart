import 'package:dilsensei/features/lesson/presentation/screens/drill_session_screen.dart';
import 'package:dilsensei/features/lesson/presentation/screens/insights_screen.dart';
import 'package:dilsensei/features/monetization/presentation/screens/paywall_screen.dart';
import 'package:dilsensei/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

final _now = DateTime(2026, 9, 1, 12, 0);

/// Progres tersimpan yang menandakan kuota gratis hari ini sudah terpakai.
const _quotaUsedToday =
    '{"streak_days":3,"last_session_date":"2026-09-01",'
    '"total_sessions":3,"best_reflex_score":77,'
    '"sessions_today":1,'
    '"pattern_miss_counts":{"particle_place":4,"past_form":2,"polite_form":1},'
    '"recent_sessions":[{"date":"2026-09-01","reflex_score":77,'
    '"first_try_correct":6,"planned_count":8}]}';

Future<void> _pumpHome(WidgetTester tester, {bool isPremium = false}) async {
  await tester.pumpWidget(
    buildTestApp(
      now: _now,
      subscriptionService: FakeSubscriptionService(isPremium: isPremium),
    ),
  );
  await pumpUntilLoaded(tester);
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('batas sesi harian', () {
    testWidgets('pengguna gratis yang masih punya kuota bisa memulai sesi', (
      tester,
    ) async {
      await _pumpHome(tester);

      await tester.tap(find.text('Mulai Sesi (5 Menit)'));
      await tester.pumpAndSettle();

      expect(find.byType(DrillSessionScreen), findsOneWidget);
    });

    testWidgets('kuota habis memunculkan penjelasan, bukan sesi', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'dilsensei.learning_progress.v1': _quotaUsedToday,
      });

      await _pumpHome(tester);

      await tester.tap(find.text('Mulai Sesi (5 Menit)'));
      await tester.pumpAndSettle();

      expect(find.byType(DrillSessionScreen), findsNothing);
      expect(find.text('Sesi hari ini sudah selesai'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Lihat paket Pro'));
      await tester.pumpAndSettle();

      expect(find.byType(PaywallScreen), findsOneWidget);
    });

    testWidgets('premium tetap bisa berlatih meski kuota harian terlewat', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'dilsensei.learning_progress.v1': _quotaUsedToday,
      });

      await _pumpHome(tester, isPremium: true);

      await tester.tap(find.text('Mulai Sesi (5 Menit)'));
      await tester.pumpAndSettle();

      expect(find.byType(DrillSessionScreen), findsOneWidget);
      expect(find.text('Sesi hari ini sudah selesai'), findsNothing);
    });
  });

  group('layar Peta Kelemahan', () {
    testWidgets('pengguna gratis hanya melihat satu pola dan ajakan Pro', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'dilsensei.learning_progress.v1': _quotaUsedToday,
      });

      await _pumpHome(tester);
      await tester.tap(find.byTooltip('Peta Kelemahan'));
      await tester.pumpAndSettle();

      expect(find.byType(InsightsScreen), findsOneWidget);
      expect(find.text('Partikel tempat'), findsOneWidget);
      expect(find.text('Bentuk lampau'), findsNothing);
      expect(find.textContaining('masih tersembunyi'), findsOneWidget);
      expect(find.text('Riwayat perkembangan terbuka di Pro.'), findsOneWidget);
    });

    testWidgets('premium melihat seluruh pola dan riwayatnya', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'dilsensei.learning_progress.v1': _quotaUsedToday,
      });

      await _pumpHome(tester, isPremium: true);
      await tester.tap(find.byTooltip('Peta Kelemahan'));
      await tester.pumpAndSettle();

      expect(find.text('Partikel tempat'), findsOneWidget);
      expect(find.text('Bentuk lampau'), findsOneWidget);
      expect(find.text('Bentuk sopan'), findsOneWidget);
      expect(find.textContaining('masih tersembunyi'), findsNothing);

      // Riwayat menampilkan tanggal, akurasi, dan skor.
      expect(find.text('1 Sep 2026'), findsOneWidget);
      expect(find.text('75% tepat'), findsOneWidget);
      expect(find.text('Total sesi'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('tanpa data menampilkan keadaan kosong yang jelas', (
      tester,
    ) async {
      await _pumpHome(tester);
      await tester.tap(find.byTooltip('Peta Kelemahan'));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada yang bisa dipetakan'), findsOneWidget);
    });
  });

  group('layar Pengaturan', () {
    testWidgets('menyediakan Restore Purchases dan kelola langganan', (
      tester,
    ) async {
      final service = FakeSubscriptionService();
      usePhoneViewport(tester);
      await tester.pumpWidget(
        buildTestApp(now: _now, subscriptionService: service),
      );
      await pumpUntilLoaded(tester);
      await tester.pump();

      await tester.tap(find.byTooltip('Pengaturan'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Versi gratis'), findsOneWidget);

      // Bagian langganan berada di bawah bagian bahasa dan pengingat.
      await tester.scrollUntilVisible(
        find.text('Kelola langganan'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Kelola langganan'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Restore Purchases'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restore Purchases'));
      await tester.pumpAndSettle();

      expect(service.restoreCallCount, 1);
    });

    testWidgets('tombol dev membuka akses Pro tanpa pembelian', (tester) async {
      await _pumpHome(tester);
      await tester.tap(find.byTooltip('Pengaturan'));
      await tester.pumpAndSettle();

      expect(find.text('Versi gratis'), findsOneWidget);

      // Bagian dev berada di bawah lipatan pada viewport test.
      await tester.scrollUntilVisible(
        find.text('DEV: Paksa akses Pro'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Tersedia karena test berjalan pada build debug.
      expect(find.text('DEV: Paksa akses Pro'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Switch>(find.byType(Switch)).value,
        isTrue,
        reason: 'override dev menyala',
      );

      // Kartu status ada di atas; gulir kembali untuk memeriksanya.
      await tester.scrollUntilVisible(
        find.text('Akses Pro aktif'),
        -220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Akses Pro aktif'), findsOneWidget);
      expect(find.text('Versi gratis'), findsNothing);

      // Kembali ke Home: modul premium tidak lagi terkunci.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_rounded), findsNothing);
    });
  });
}
