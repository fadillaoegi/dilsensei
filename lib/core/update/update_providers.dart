import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_update_service.dart';
import 'play_app_update_service.dart';

/// Tahapan yang dilihat pengguna.
enum UpdateStage {
  /// Tidak ada yang perlu ditampilkan.
  idle,

  /// Ada pembaruan dan bisa diunduh dari dalam app.
  available,

  /// Sedang diunduh di latar.
  downloading,

  /// Sudah terunduh; menunggu pengguna menyetujui pemasangan.
  readyToInstall,

  /// Gagal memulai. Pengguna diarahkan ke Play, bukan dibiarkan menebak.
  failed,
}

class UpdateState {
  const UpdateState({this.stage = UpdateStage.idle, this.versionCode});

  final UpdateStage stage;
  final int? versionCode;

  UpdateState copyWith({UpdateStage? stage, int? versionCode}) {
    return UpdateState(
      stage: stage ?? this.stage,
      versionCode: versionCode ?? this.versionCode,
    );
  }

  /// True bila ada sesuatu yang perlu ditampilkan di Home.
  bool get isVisible => stage != UpdateStage.idle;
}

/// Mengelola tawaran pembaruan.
///
/// Dua aturan yang disengaja. Pertama, pemeriksaan dilakukan **sekali** per
/// hidup controller, bukan setiap kali Home dibangun — memeriksa berulang kali
/// membuang kuota dan tidak menambah informasi. Kedua, tawaran dapat ditutup;
/// app latihan tidak boleh menyandera pengguna dengan spanduk yang tidak bisa
/// hilang.
class UpdateController extends StateNotifier<UpdateState> {
  UpdateController({required this.service, bool checkOnStart = true})
    : super(const UpdateState()) {
    if (checkOnStart) check();
  }

  final AppUpdateService service;

  bool _hasChecked = false;

  Future<void> check() async {
    if (_hasChecked) return;
    _hasChecked = true;

    final info = await service.check();
    if (!mounted) return;

    if (!info.canUpdateInApp) return;

    state = UpdateState(
      stage: UpdateStage.available,
      versionCode: info.availableVersionCode,
    );
  }

  Future<void> startDownload() async {
    if (state.stage == UpdateStage.downloading) return;

    state = state.copyWith(stage: UpdateStage.downloading);

    final result = await service.startFlexibleUpdate();
    if (!mounted) return;

    state = switch (result) {
      UpdateStartResult.started => state.copyWith(
        stage: UpdateStage.readyToInstall,
      ),
      // Penolakan pengguna bukan galat: tawarannya hanya ditutup.
      UpdateStartResult.userCancelled => const UpdateState(),
      UpdateStartResult.failed => state.copyWith(stage: UpdateStage.failed),
    };
  }

  Future<void> install() async {
    final isInstalled = await service.completeFlexibleUpdate();
    if (!mounted) return;

    // Bila berhasil, Play memulai ulang app sehingga state ini tidak terlihat
    // lagi. Bila gagal, pengguna diberi jalan keluar.
    if (!isInstalled) state = state.copyWith(stage: UpdateStage.failed);
  }

  /// Menutup tawaran sampai app dijalankan berikutnya.
  void dismiss() => state = const UpdateState();
}

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  // In-App Updates adalah fitur Google Play, jadi hanya Android yang relevan.
  if (kIsWeb || !Platform.isAndroid) {
    return const UnavailableAppUpdateService();
  }

  return const PlayAppUpdateService();
});

final updateControllerProvider =
    StateNotifierProvider<UpdateController, UpdateState>((ref) {
      return UpdateController(service: ref.watch(appUpdateServiceProvider));
    });
