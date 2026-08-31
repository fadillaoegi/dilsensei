import 'package:dilsensei/core/diagnostics/diagnostics_log.dart';
import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('log diagnostik', () {
    test('mencatat dan memformat entri', () {
      final log = DiagnosticsLog();
      addTearDown(log.dispose);

      log.record('revenuecat', 'pembelian dimulai', detail: 'paket=monthly');

      expect(log.entries, hasLength(1));

      final line = log.entries.single.format();
      expect(line, contains('INFO'));
      expect(line, contains('[revenuecat]'));
      expect(line, contains('pembelian dimulai'));
      expect(line, contains('paket=monthly'));
    });

    test('membuang entri tertua saat kapasitas terlampaui', () {
      final log = DiagnosticsLog(capacity: 3);
      addTearDown(log.dispose);

      for (var i = 1; i <= 5; i++) {
        log.record('uji', 'entri $i');
      }

      expect(log.entries, hasLength(3));
      expect(log.entries.first.message, 'entri 3');
      expect(log.entries.last.message, 'entri 5');
    });

    test('memberi tahu pendengar setiap ada catatan baru', () {
      final log = DiagnosticsLog();
      addTearDown(log.dispose);

      var notifications = 0;
      log.addListener(() => notifications++);

      log.record('uji', 'a');
      log.record('uji', 'b');

      expect(notifications, 2);
    });

    test('teks gabungan urut dari yang paling awal', () {
      final log = DiagnosticsLog();
      addTearDown(log.dispose);

      log.record('uji', 'pertama');
      log.record('uji', 'kedua');

      final text = log.asText();
      expect(text.indexOf('pertama'), lessThan(text.indexOf('kedua')));
    });

    test('tingkat galat tercatat sebagai ERROR', () {
      final log = DiagnosticsLog();
      addTearDown(log.dispose);

      log.record('uji', 'gagal', level: DiagnosticSeverity.error);

      expect(log.entries.single.format(), contains('ERROR'));
    });
  });

  group('penyamaran kunci', () {
    test(
      'kunci panjang hanya menampilkan prefiks dan empat huruf terakhir',
      () {
        final masked = maskKey('goog_yhYUxqEwsyIluACOTgGRLkTALuo');

        expect(masked, startsWith('goog_'));
        expect(masked, endsWith('ALuo'));
        expect(masked, isNot(contains('yhYUxqEwsyIluACOTgGRLkT')));
      },
    );

    test('kunci kosong dilaporkan apa adanya', () {
      expect(maskKey(''), '(kosong)');
    });

    test('kunci pendek tidak membocorkan sisanya', () {
      expect(maskKey('test_abc'), 'test_...');
    });
  });

  group('layar diagnostik', () {
    testWidgets('tidak muncul di Pengaturan bila dimatikan', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(
        buildTestApp(language: AppLanguage.english, diagnosticsEnabled: false),
      );
      await pumpUntilLoaded(tester);
      await tester.pump();

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.text('Diagnostics'), findsNothing);
    });

    testWidgets('menampilkan catatan dan bisa disalin', (tester) async {
      // Papan klip dipalsukan agar test tidak menyentuh platform.
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      final log = DiagnosticsLog();
      addTearDown(log.dispose);
      log.record(
        'revenuecat',
        'offering dimuat',
        detail: 'jumlahPaket=0',
        level: DiagnosticSeverity.error,
      );

      usePhoneViewport(tester);
      await tester.pumpWidget(
        buildTestApp(
          language: AppLanguage.english,
          diagnosticsEnabled: true,
          diagnosticsLog: log,
        ),
      );
      await pumpUntilLoaded(tester);
      await tester.pump();

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Diagnostics').last);
      await tester.pumpAndSettle();

      expect(find.text('offering dimuat'), findsOneWidget);
      expect(find.text('jumlahPaket=0'), findsOneWidget);

      await tester.tap(find.byTooltip('Copy all'));
      await tester.pumpAndSettle();

      expect(copied, hasLength(1));
      expect(copied.single, contains('offering dimuat'));
      expect(copied.single, contains('jumlahPaket=0'));
    });

    testWidgets('keadaan kosong menjelaskan cara mengisinya', (tester) async {
      final log = DiagnosticsLog();
      addTearDown(log.dispose);

      usePhoneViewport(tester);
      await tester.pumpWidget(
        buildTestApp(
          language: AppLanguage.english,
          diagnosticsEnabled: true,
          diagnosticsLog: log,
        ),
      );
      await pumpUntilLoaded(tester);
      await tester.pump();

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Diagnostics').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Nothing recorded yet'), findsOneWidget);
    });
  });
}
