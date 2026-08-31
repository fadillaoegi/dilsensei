import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart' as play;

import 'app_update_service.dart';

/// Implementasi pembaruan di atas Google Play In-App Updates.
///
/// Hanya berfungsi bila app dipasang dari Google Play. Pada build debug,
/// pemasangan sideload, atau perangkat tanpa Play Store, Play melempar galat —
/// dan itu keadaan normal, bukan kerusakan. Karena itu [check] selalu
/// mengembalikan [AppUpdateInfo.unknown] ketimbang meneruskan galatnya.
class PlayAppUpdateService implements AppUpdateService {
  const PlayAppUpdateService();

  @override
  Future<AppUpdateInfo> check() async {
    try {
      final info = await play.InAppUpdate.checkForUpdate();

      return AppUpdateInfo(
        availability: _availabilityFrom(info.updateAvailability),
        isFlexibleAllowed: info.flexibleUpdateAllowed,
        availableVersionCode: info.availableVersionCode,
        stalenessDays: info.clientVersionStalenessDays,
      );
    } on Object catch (error) {
      debugPrint('PEMBARUAN: pemeriksaan tidak tersedia: $error');

      return const AppUpdateInfo.unknown();
    }
  }

  @override
  Future<UpdateStartResult> startFlexibleUpdate() async {
    try {
      final result = await play.InAppUpdate.startFlexibleUpdate();

      return switch (result) {
        play.AppUpdateResult.success => UpdateStartResult.started,
        play.AppUpdateResult.userDeniedUpdate =>
          UpdateStartResult.userCancelled,
        play.AppUpdateResult.inAppUpdateFailed => UpdateStartResult.failed,
      };
    } on Object catch (error) {
      debugPrint('PEMBARUAN: gagal memulai unduhan: $error');

      return UpdateStartResult.failed;
    }
  }

  @override
  Future<bool> completeFlexibleUpdate() async {
    try {
      await play.InAppUpdate.completeFlexibleUpdate();

      return true;
    } on Object catch (error) {
      debugPrint('PEMBARUAN: gagal memasang: $error');

      return false;
    }
  }

  UpdateAvailability _availabilityFrom(play.UpdateAvailability value) {
    return switch (value) {
      play.UpdateAvailability.updateAvailable => UpdateAvailability.available,
      play.UpdateAvailability.updateNotAvailable => UpdateAvailability.upToDate,
      // developerTriggeredUpdateInProgress dan unknown sama-sama tidak
      // menghasilkan tawaran baru bagi pengguna.
      _ => UpdateAvailability.unknown,
    };
  }
}

/// Layanan pembaruan yang tidak pernah menawarkan apa pun.
///
/// Dipakai pada platform selain Android dan pada seluruh test, supaya test tidak
/// menyentuh Play Core.
class UnavailableAppUpdateService implements AppUpdateService {
  const UnavailableAppUpdateService();

  @override
  Future<AppUpdateInfo> check() async => const AppUpdateInfo.unknown();

  @override
  Future<UpdateStartResult> startFlexibleUpdate() async =>
      UpdateStartResult.failed;

  @override
  Future<bool> completeFlexibleUpdate() async => false;
}
