import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFFCFCFC);
  static const primary = Color(0xFF2D6A4F);
  static const secondary = Color(0xFFD8F3DC);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const error = Color(0xFFBA1A1A);
  static const white = Color(0xFFFFFFFF);
}

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
  static const ColorScheme _colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    secondary: AppColors.secondary,
    onSecondary: AppColors.primary,
    surface: AppColors.background,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.white,
  );

  static ThemeData get light {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.japaneseFallback,
    );

    final textTheme = _buildTextTheme(baseTheme.textTheme);

    return baseTheme.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.secondary,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
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
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
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
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorder(color: AppColors.primary, width: 1.5),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.primary.withValues(alpha: 0.12),
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Heading memakai Space Grotesk dengan letter-spacing negatif; body memakai
  /// Plus Jakarta Sans.
  static TextTheme _buildTextTheme(TextTheme base) {
    TextStyle? heading(TextStyle? style) => style?.copyWith(
      fontFamily: AppFonts.display,
      fontFamilyFallback: AppFonts.japaneseFallback,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    );

    TextStyle? body(TextStyle? style, {Color? color}) => style?.copyWith(
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.japaneseFallback,
      color: color ?? AppColors.textPrimary,
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
      bodyMedium: body(base.bodyMedium, color: AppColors.textSecondary),
      bodySmall: body(base.bodySmall, color: AppColors.textSecondary),
      labelLarge: body(base.labelLarge),
      labelMedium: body(base.labelMedium),
      labelSmall: body(base.labelSmall),
    );
  }

  static OutlineInputBorder _inputBorder({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: color ?? AppColors.primary.withValues(alpha: 0.16),
        width: width,
      ),
    );
  }
}
