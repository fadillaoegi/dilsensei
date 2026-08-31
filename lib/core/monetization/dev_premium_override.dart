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

/// Gerbang render untuk blok perkakas dev.
///
/// Nilainya berasal dari [DevTools.isEnabled], tapi dibungkus provider supaya
/// test bisa menirukan build release — `kDebugMode` adalah konstanta, sehingga
/// tanpa ini perilaku rilis hanya bisa diasumsikan, tidak diuji.
///
/// Perhatikan bahwa [isDevPremiumActiveProvider] tetap memeriksa
/// [DevTools.isEnabled] secara langsung. Jadi walau gerbang render ini ditimpa,
/// konten premium tetap tidak mungkin terbuka gratis di build release.
final devToolsEnabledProvider = Provider<bool>((ref) => DevTools.isEnabled);

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
