import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Perkakas pengembangan untuk memaksa akses Pro tanpa pembelian.
///
/// ATURAN KERAS: hanya berfungsi pada build debug atau profile. Pada build
/// release, [isEnabled] selalu false sehingga tombolnya tidak dirender dan
/// override-nya diabaikan — konten premium tidak mungkin terbuka gratis di
/// produksi, bahkan bila kode ini lupa dihapus.
abstract final class DevTools {
  static bool get isEnabled => kDebugMode || kProfileMode;
}

/// Status override yang dikendalikan tombol dev.
class DevPremiumOverride extends StateNotifier<bool> {
  DevPremiumOverride() : super(false);

  void toggle() {
    if (!DevTools.isEnabled) return;

    state = !state;
  }
}

final devPremiumOverrideProvider =
    StateNotifierProvider<DevPremiumOverride, bool>((ref) {
      return DevPremiumOverride();
    });

/// True hanya bila perkakas dev aktif DAN override dinyalakan.
final isDevPremiumActiveProvider = Provider<bool>((ref) {
  if (!DevTools.isEnabled) return false;

  return ref.watch(devPremiumOverrideProvider);
});
