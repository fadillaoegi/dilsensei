import 'package:flutter/material.dart';

import 'app_palette.dart';

export 'app_palette.dart' show AppColors, AppPalette, AppPaletteX;

abstract final class AppFonts {
  /// Heading: grotesk berkarakter.
  static const display = 'Space Grotesk';

  /// Body: sans-serif bersih buatan foundry Indonesia (Tokotype).
  static const body = 'Plus Jakarta Sans';

  /// Kedua font di atas hanya memuat glif Latin. Aksara Jepang dirender oleh
  /// font sistem lewat rantai fallback ini.
  static const japaneseFallback = <String>[
    'Noto Sans JP',
    'Noto Sans CJK JP',
    'Hiragino Sans',
    'sans-serif',
  ];
}

abstract final class AppTheme {
  static ThemeData get light =>
      _build(AppPalette.light, brightness: Brightness.light);

  static ThemeData get dark =>
      _build(AppPalette.dark, brightness: Brightness.dark);

  /// Satu jalur pembangun tema untuk kedua mode.
  ///
  /// Dibuat dari [palette] supaya tidak ada nilai warna yang ditulis dua kali;
  /// menambah peran warna baru cukup di [AppPalette].
  static ThemeData _build(
    AppPalette palette, {
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      secondary: palette.surfaceAccent,
      onSecondary: palette.primary,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      error: palette.error,
      onError: palette.onError,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.surface,
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.japaneseFallback,
      extensions: <ThemeExtension<dynamic>>[palette],
    );

    final textTheme = _buildTextTheme(baseTheme.textTheme, palette);

    return baseTheme.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: palette.surface,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: palette.surfaceAccent,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.primary.withValues(alpha: 0.12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          disabledBackgroundColor: palette.primary.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: _inputBorder(palette),
        enabledBorder: _inputBorder(palette),
        focusedBorder: _inputBorder(
          palette,
          color: palette.primary,
          width: 1.5,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.primary.withValues(alpha: 0.12),
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Heading memakai Space Grotesk dengan letter-spacing negatif; body memakai
  /// Plus Jakarta Sans.
  static TextTheme _buildTextTheme(TextTheme base, AppPalette palette) {
    TextStyle? heading(TextStyle? style) => style?.copyWith(
      fontFamily: AppFonts.display,
      fontFamilyFallback: AppFonts.japaneseFallback,
      color: palette.textPrimary,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    );

    TextStyle? body(TextStyle? style, {Color? color}) => style?.copyWith(
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.japaneseFallback,
      color: color ?? palette.textPrimary,
    );

    return base.copyWith(
      displayLarge: heading(base.displayLarge),
      displayMedium: heading(base.displayMedium),
      displaySmall: heading(base.displaySmall),
      headlineLarge: heading(base.headlineLarge),
      headlineMedium: heading(base.headlineMedium),
      headlineSmall: heading(base.headlineSmall),
      titleLarge: heading(base.titleLarge),
      titleMedium: body(base.titleMedium),
      titleSmall: body(base.titleSmall),
      bodyLarge: body(base.bodyLarge),
      bodyMedium: body(base.bodyMedium, color: palette.textSecondary),
      bodySmall: body(base.bodySmall, color: palette.textSecondary),
      labelLarge: body(base.labelLarge),
      labelMedium: body(base.labelMedium),
      labelSmall: body(base.labelSmall),
    );
  }

  static OutlineInputBorder _inputBorder(
    AppPalette palette, {
    Color? color,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: color ?? palette.primary.withValues(alpha: 0.16),
        width: width,
      ),
    );
  }
}
