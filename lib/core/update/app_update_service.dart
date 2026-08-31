/// Ketersediaan pembaruan menurut Google Play.
enum UpdateAvailability {
  /// Tidak diketahui: app tidak dipasang dari Play, perangkat offline, atau
  /// Play Store tidak tersedia. Diperlakukan sama seperti tidak ada pembaruan.
  unknown,
  upToDate,
  available,
}

/// Hasil pemeriksaan pembaruan.
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.availability,
    this.isFlexibleAllowed = false,
    this.availableVersionCode,
    this.stalenessDays,
  });

  const AppUpdateInfo.unknown()
    : availability = UpdateAvailability.unknown,
      isFlexibleAllowed = false,
      availableVersionCode = null,
      stalenessDays = null;

  final UpdateAvailability availability;

  /// True bila Play mengizinkan pembaruan fleksibel, yaitu mengunduh di latar
  /// tanpa memblokir pemakaian app.
  final bool isFlexibleAllowed;

  final int? availableVersionCode;

  /// Berapa hari versi terpasang sudah ketinggalan, bila Play melaporkannya.
  final int? stalenessDays;

  /// True hanya bila ada pembaruan yang benar-benar bisa dijalankan dari app.
  bool get canUpdateInApp =>
      availability == UpdateAvailability.available && isFlexibleAllowed;
}

/// Hasil upaya memulai pembaruan.
///
/// Dibedakan supaya UI tidak menampilkan pesan galat ketika pengguna memang
/// sengaja membatalkan. Sama seperti pembelian, service melaporkan sebab dan UI
/// yang memilih kalimatnya.
enum UpdateStartResult { started, userCancelled, failed }

/// Kontrak pembaruan dalam app.
///
/// Seluruh tipe milik Play Core berhenti di implementasinya, sehingga UI dan
/// test tidak pernah menyentuh platform.
abstract interface class AppUpdateService {
  /// Memeriksa ketersediaan pembaruan. Tidak boleh melempar: kegagalan
  /// dilaporkan sebagai [AppUpdateInfo.unknown].
  Future<AppUpdateInfo> check();

  /// Mulai mengunduh pembaruan di latar.
  Future<UpdateStartResult> startFlexibleUpdate();

  /// Memasang pembaruan yang sudah terunduh; Play akan memulai ulang app.
  /// Mengembalikan false bila pemasangan gagal dijalankan.
  Future<bool> completeFlexibleUpdate();
}
