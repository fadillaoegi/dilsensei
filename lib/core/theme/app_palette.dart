import 'package:flutter/material.dart';

/// Konstanta merek. Hanya palet dan alat di `tool/` yang boleh memakainya
/// langsung; UI memakai [AppPalette] lewat `context.palette` supaya ikut
/// berubah saat mode gelap aktif.
abstract final class AppColors {
  static const background = Color(0xFFFCFCFC);
  static const primary = Color(0xFF2D6A4F);
  static const secondary = Color(0xFFD8F3DC);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const error = Color(0xFFBA1A1A);
  static const white = Color(0xFFFFFFFF);
}

/// Warna berdasarkan **peran**, bukan berdasarkan nama warnanya.
///
/// Ini yang memungkinkan mode gelap: sebuah widget meminta "isian kartu"
/// ([surfaceCard]) alih-alih meminta "putih", sehingga nilainya bisa berbeda
/// antar tema tanpa mengubah widget.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.surface,
    required this.surfaceCard,
    required this.surfaceAccent,
    required this.primary,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    required this.onError,
  });

  /// Latar halaman.
  final Color surface;

  /// Isian kartu atau petak yang naik satu tingkat dari [surface].
  final Color surfaceCard;

  /// Isian untuk keadaan terpilih, ditonjolkan, atau kartu bernuansa merek.
  final Color surfaceAccent;

  final Color primary;

  /// Konten di atas [primary]; pada mode gelap ini justru gelap.
  final Color onPrimary;

  final Color textPrimary;
  final Color textSecondary;
  final Color error;
  final Color onError;

  /// Palet terang: Organic Minimalism seperti semula.
  static const light = AppPalette(
    surface: AppColors.background,
    surfaceCard: AppColors.white,
    surfaceAccent: AppColors.secondary,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    error: AppColors.error,
    onError: AppColors.white,
  );

  /// Palet gelap.
  ///
  /// Hijau merek dinaikkan ke #74C69D — masih satu keluarga dengan #2D6A4F,
  /// tapi cukup terang untuk dibaca di atas latar gelap. Latar tidak memakai
  /// hitam netral melainkan hitam bernuansa hijau, supaya identitas visualnya
  /// tetap terasa.
  static const dark = AppPalette(
    surface: Color(0xFF0F1512),
    surfaceCard: Color(0xFF171F1A),
    surfaceAccent: Color(0xFF1F3329),
    primary: Color(0xFF74C69D),
    onPrimary: Color(0xFF0B2418),
    textPrimary: Color(0xFFF1F4F1),
    textSecondary: Color(0xFFA2ADA6),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
  );

  @override
  AppPalette copyWith({
    Color? surface,
    Color? surfaceCard,
    Color? surfaceAccent,
    Color? primary,
    Color? onPrimary,
    Color? textPrimary,
    Color? textSecondary,
    Color? error,
    Color? onError,
  }) {
    return AppPalette(
      surface: surface ?? this.surface,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceAccent: surfaceAccent ?? this.surfaceAccent,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      error: error ?? this.error,
      onError: onError ?? this.onError,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;

    return AppPalette(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceAccent: Color.lerp(surfaceAccent, other.surfaceAccent, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
    );
  }

  /// Kesetaraan berbasis nilai. Dibutuhkan antara lain oleh `shouldRepaint`
  /// pada CustomPainter yang menerima palet: tanpa ini, perubahan tema tidak
  /// memicu gambar ulang.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppPalette &&
        other.surface == surface &&
        other.surfaceCard == surfaceCard &&
        other.surfaceAccent == surfaceAccent &&
        other.primary == primary &&
        other.onPrimary == onPrimary &&
        other.textPrimary == textPrimary &&
        other.textSecondary == textSecondary &&
        other.error == error &&
        other.onError == onError;
  }

  @override
  int get hashCode => Object.hash(
    surface,
    surfaceCard,
    surfaceAccent,
    primary,
    onPrimary,
    textPrimary,
    textSecondary,
    error,
    onError,
  );
}

/// Akses singkat ke palet aktif.
///
/// Selalu mengembalikan nilai: bila ekstensi belum terpasang (misalnya widget
/// diuji di luar AppTheme), palet terang dipakai sebagai cadangan agar UI tidak
/// kehilangan warna.
extension AppPaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
