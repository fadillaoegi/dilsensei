/// Isi satu notifikasi pengingat yang siap ditampilkan.
class ReminderContent {
  const ReminderContent({
    required this.title,
    required this.body,
    required this.scheduledFor,
  });

  final String title;
  final String body;
  final DateTime scheduledFor;
}

/// Kontrak penjadwal pengingat.
///
/// Layer presentation hanya mengenal kontrak ini, sehingga aturan pengingat bisa
/// diuji tanpa perangkat dan implementasi platform bisa ditukar — misalnya nanti
/// ke push lewat OneSignal — tanpa mengubah UI.
abstract interface class ReminderScheduler {
  /// Menyiapkan penjadwal. Aman dipanggil lebih dari sekali.
  Future<void> initialize();

  /// Meminta izin notifikasi. Mengembalikan true bila diizinkan.
  Future<bool> requestPermission();

  /// Menjadwalkan satu pengingat harian, menggantikan yang sebelumnya.
  Future<void> schedule(ReminderContent content);

  /// Membatalkan pengingat yang terjadwal.
  Future<void> cancel();
}
