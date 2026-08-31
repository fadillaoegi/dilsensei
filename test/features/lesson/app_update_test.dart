import 'package:dilsensei/core/localization/language_controller.dart';
import 'package:dilsensei/core/update/app_update_service.dart';
import 'package:dilsensei/core/update/play_app_update_service.dart';
import 'package:dilsensei/core/update/update_providers.dart';
import 'package:dilsensei/features/lesson/presentation/widgets/update_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/lesson_test_fixtures.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('controller pembaruan', () {
    test(
      'tidak menawarkan apa pun bila Play tidak melaporkan pembaruan',
      () async {
        final service = FakeAppUpdateService();
        final controller = UpdateController(service: service);
        addTearDown(controller.dispose);
        await Future<void>.delayed(Duration.zero);

        expect(controller.state.stage, UpdateStage.idle);
        expect(controller.state.isVisible, isFalse);
      },
    );

    test('pembaruan tanpa izin fleksibel tidak ditawarkan', () async {
      // Play bisa melaporkan ada pembaruan tapi menolak jalur fleksibel.
      // Menawarkannya tetap hanya akan menghasilkan kegagalan.
      final service = FakeAppUpdateService(
        info: const AppUpdateInfo(
          availability: UpdateAvailability.available,
          isFlexibleAllowed: false,
        ),
      );
      final controller = UpdateController(service: service);
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.stage, UpdateStage.idle);
    });

    test('pembaruan tersedia memunculkan tawaran beserta versinya', () async {
      final service = FakeAppUpdateService(info: availableUpdate);
      final controller = UpdateController(service: service);
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.stage, UpdateStage.available);
      expect(controller.state.versionCode, 7);
    });

    test(
      'pemeriksaan hanya berjalan sekali meski dipanggil berulang',
      () async {
        final service = FakeAppUpdateService(info: availableUpdate);
        final controller = UpdateController(service: service);
        addTearDown(controller.dispose);
        await Future<void>.delayed(Duration.zero);

        await controller.check();
        await controller.check();

        expect(service.checkCount, 1);
      },
    );

    test('unduhan berhasil berpindah ke tahap siap pasang', () async {
      final service = FakeAppUpdateService(info: availableUpdate);
      final controller = UpdateController(service: service);
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);

      await controller.startDownload();

      expect(service.startCount, 1);
      expect(controller.state.stage, UpdateStage.readyToInstall);
    });

    test('pengguna membatalkan tidak dianggap galat', () async {
      final service = FakeAppUpdateService(
        info: availableUpdate,
        startResult: UpdateStartResult.userCancelled,
      );
      final controller = UpdateController(service: service);
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);

      await controller.startDownload();

      expect(controller.state.stage, UpdateStage.idle);
      expect(controller.state.stage, isNot(UpdateStage.failed));
    });

    test('kegagalan Play menghasilkan tahap gagal, bukan lemparan', () async {
      final service = FakeAppUpdateService(
        info: availableUpdate,
        startResult: UpdateStartResult.failed,
      );
      final controller = UpdateController(service: service);
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);

      await controller.startDownload();

      expect(controller.state.stage, UpdateStage.failed);
    });

    test('pemasangan gagal memberi tahu pengguna', () async {
      final service = FakeAppUpdateService(
        info: availableUpdate,
        installSucceeds: false,
      );
      final controller = UpdateController(service: service);
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);

      await controller.startDownload();
      await controller.install();

      expect(service.installCount, 1);
      expect(controller.state.stage, UpdateStage.failed);
    });

    test('tawaran dapat ditutup pengguna', () async {
      final service = FakeAppUpdateService(info: availableUpdate);
      final controller = UpdateController(service: service);
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);

      controller.dismiss();

      expect(controller.state.isVisible, isFalse);
    });

    test('layanan tidak tersedia tidak melempar saat dipakai', () async {
      // Build debug dan pemasangan sideload memakai jalur ini.
      const service = UnavailableAppUpdateService();

      expect((await service.check()).canUpdateInApp, isFalse);
      expect(await service.startFlexibleUpdate(), UpdateStartResult.failed);
      expect(await service.completeFlexibleUpdate(), isFalse);
    });
  });

  group('dialog di Home', () {
    testWidgets('tidak ada dialog bila tidak ada pembaruan', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(
        buildTestApp(
          language: AppLanguage.english,
          updateService: FakeAppUpdateService(),
        ),
      );
      await pumpUntilLoaded(tester);
      await tester.pumpAndSettle();

      expect(find.byType(UpdateDialog), findsNothing);
      expect(find.text('Update available'), findsNothing);
      // Home tetap berfungsi normal.
      expect(find.text('Start session (5 min)'), findsOneWidget);
    });

    testWidgets('dialog muncul dan mengunduh saat ditekan', (tester) async {
      final service = FakeAppUpdateService(info: availableUpdate);

      usePhoneViewport(tester);
      await tester.pumpWidget(
        buildTestApp(language: AppLanguage.english, updateService: service),
      );
      await pumpUntilLoaded(tester);
      await tester.pumpAndSettle();

      expect(find.byType(UpdateDialog), findsOneWidget);
      expect(find.text('Update available'), findsOneWidget);

      await tester.tap(find.text('Update now'));
      await tester.pumpAndSettle();

      // Dialog menutup; banner mengambil alih perkembangannya.
      expect(find.byType(UpdateDialog), findsNothing);
      expect(service.startCount, 1);
      expect(find.text('Update ready'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);
    });

    testWidgets('tombol Nanti menutup tawaran sepenuhnya', (tester) async {
      final service = FakeAppUpdateService(info: availableUpdate);

      usePhoneViewport(tester);
      await tester.pumpWidget(
        buildTestApp(language: AppLanguage.english, updateService: service),
      );
      await pumpUntilLoaded(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      expect(find.byType(UpdateDialog), findsNothing);
      expect(find.text('Update available'), findsNothing);
      // Menolak tawaran tidak boleh diam-diam memulai unduhan.
      expect(service.startCount, 0);
    });

    testWidgets('dialog hanya ditawarkan sekali per hidup app', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(
        buildTestApp(
          language: AppLanguage.english,
          updateService: FakeAppUpdateService(info: availableUpdate),
        ),
      );
      await pumpUntilLoaded(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      // Pergi ke layar lain lalu kembali: Home dibangun ulang, tapi tawaran
      // yang sudah ditolak tidak boleh muncul lagi.
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(UpdateDialog), findsNothing);
    });

    testWidgets('kegagalan mengarahkan ke Google Play', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(
        buildTestApp(
          language: AppLanguage.english,
          updateService: FakeAppUpdateService(
            info: availableUpdate,
            startResult: UpdateStartResult.failed,
          ),
        ),
      );
      await pumpUntilLoaded(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update now'));
      await tester.pumpAndSettle();

      expect(find.text('Update could not start'), findsOneWidget);
      expect(find.text('Open Google Play'), findsOneWidget);
    });

    testWidgets('dialog ikut diterjemahkan', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(
        buildTestApp(
          language: AppLanguage.indonesian,
          updateService: FakeAppUpdateService(info: availableUpdate),
        ),
      );
      await pumpUntilLoaded(tester);
      await tester.pumpAndSettle();

      expect(find.text('Pembaruan tersedia'), findsOneWidget);
      expect(find.text('Perbarui sekarang'), findsOneWidget);
      expect(find.text('Nanti'), findsOneWidget);
      expect(find.text('Update available'), findsNothing);
    });
  });
}
